# ============================================================================================================================================================
# PSO ỨNG DỤNG TÌM THAM SỐ VẬT LIỆU SIÊU ĐÀN HỒI (YEOH)
# ============================================================================================================================================================

using Random
using Printf
using DelimitedFiles
using Plots

# ==============================================================================
# 1. CONSTITIVE MODELS
# ==============================================================================
abstract type HyperelasticModel end

struct Yeoh <: HyperelasticModel end
struct NeoHookean <: HyperelasticModel end # Test

# Yeoh
function nominal_stress(::Yeoh, lambda::Float64, params::Vector{Float64})
    C10, C20, C30 = params
    I1 = lambda^2 + 2.0 / lambda
    # Phương trình ứng suất kéo đơn trục
    return 2.0 * (lambda - 1.0 / lambda^2) * (C10 + 2.0 * C20 * (I1 - 3.0) + 3.0 * C30 * (I1 - 3.0)^2)
end

# Neo-Hookean (ko xài)
function nominal_stress(::NeoHookean, lambda::Float64, params::Vector{Float64})
    C10 = params[1]
    return 2.0 * C10 * (lambda - 1.0 / lambda^2)
end

# ==============================================================================
# 2. STRUCTs
# ==============================================================================
mutable struct Particle
    position::Vector{Float64}
    velocity::Vector{Float64}
    pbest_pos::Vector{Float64}
    pbest_val::Float64
end

mutable struct Swarm
    particles::Vector{Particle}
    gbest_pos::Vector{Float64}
    gbest_val::Float64
end

# ==============================================================================
# 3. HÀM ĐÁNH GIÁ
# ==============================================================================
function check_constraints(params::Vector{Float64})
    C10, C20, C30 = params
    # Ràng buộc g(x) <= 0
    g1 = -C10                              # C10 > 0
    g2 = C20^2 - 3.0 * C10 * C30           # Ổn định Drucker
    g3 = C10 - 1.0

    penalty = max(0.0, g1)^2 + max(0.0, g2)^2 + max(0.0, g3)^2
    return penalty
end

function evaluate_fitness(model::HyperelasticModel, params::Vector{Float64}, lambda_exp::Vector{Float64}, P_exp::Vector{Float64})
    penalty = check_constraints(params)

    if penalty > 0.0
        return 1e6 + 1e6 * penalty
    end

    # MSE
    mse = 0.0
    n_points = length(lambda_exp)
    for i in 1:n_points
        P_num = nominal_stress(model, lambda_exp[i], params)
        mse += (P_num - P_exp[i])^2
    end
    return mse / n_points
end

# P_best for 1 p
function evaluate_fitness!(particle::Particle, model::HyperelasticModel, lambda_exp::Vector{Float64}, P_exp::Vector{Float64})
    fit = evaluate_fitness(model, particle.position, lambda_exp, P_exp)

    # Update Pbest
    if fit < particle.pbest_val
        particle.pbest_val = fit
        particle.pbest_pos = copy(particle.position)
    end
    return fit
end

# ==============================================================================
# 4. PSO
# ==============================================================================
function init_swarm(model::HyperelasticModel, lambda_exp::Vector{Float64}, P_exp::Vector{Float64};
    num_particles=30, dim=3, bound_min=[-0.5, -0.5, -0.5], bound_max=[1.5, 0.5, 0.5])

    swarm = Swarm(Particle[], zeros(dim), Inf)

    for i in 1:num_particles
        pos = bound_min .+ rand(dim) .* (bound_max .- bound_min)
        vel = zeros(dim)
        p = Particle(pos, vel, copy(pos), Inf)

        fit = evaluate_fitness!(p, model, lambda_exp, P_exp)
        if fit < swarm.gbest_val
            swarm.gbest_val = fit
            swarm.gbest_pos = copy(p.position)
        end
        push!(swarm.particles, p)
    end

    return swarm
end

# Standard PSO w const
function run_pso(model::HyperelasticModel, lambda_exp::Vector{Float64}, P_exp::Vector{Float64};
    num_particles=30, max_iter=100, dim=3, return_history=false)

    w = 0.7
    c1 = 1.5
    c2 = 1.5
    swarm = init_swarm(model, lambda_exp, P_exp, num_particles=num_particles, dim=dim)
    history = Vector{Float64}(undef, max_iter)

    for iter in 1:max_iter
        for p in swarm.particles
            r1, r2 = rand(dim), rand(dim)
            p.velocity .= w .* p.velocity .+
                          c1 .* r1 .* (p.pbest_pos .- p.position) .+
                          c2 .* r2 .* (swarm.gbest_pos .- p.position)

            p.position .= p.position .+ p.velocity

            fit = evaluate_fitness!(p, model, lambda_exp, P_exp)
            if fit < swarm.gbest_val
                swarm.gbest_val = fit
                swarm.gbest_pos = copy(p.position)
            end
        end

        if iter % 200 == 0
            @printf("[STD] Iter %5d | MSE: %.6e | Param: [%.4f, %.4f, %.4f]\n",
                iter, swarm.gbest_val, swarm.gbest_pos[1], swarm.gbest_pos[2], swarm.gbest_pos[3])
        end
        history[iter] = swarm.gbest_val
    end

    if return_history
        return swarm.gbest_pos, swarm.gbest_val, history
    end
    return swarm.gbest_pos, swarm.gbest_val
end

# PSO wmax -> wmin
function run_pso_dynamic_w(model::HyperelasticModel, lambda_exp::Vector{Float64}, P_exp::Vector{Float64};
    num_particles=30, max_iter=100, dim=3, w_max=0.9, w_min=0.4, return_history=false)

    c1 = 1.5
    c2 = 1.5
    swarm = init_swarm(model, lambda_exp, P_exp, num_particles=num_particles, dim=dim)
    history = Vector{Float64}(undef, max_iter)
    denom = max(max_iter - 1, 1)

    for iter in 1:max_iter
        w = w_max - (w_max - w_min) * (iter - 1) / denom

        for p in swarm.particles
            r1, r2 = rand(dim), rand(dim)
            p.velocity .= w .* p.velocity .+
                          c1 .* r1 .* (p.pbest_pos .- p.position) .+
                          c2 .* r2 .* (swarm.gbest_pos .- p.position)

            p.position .= p.position .+ p.velocity

            fit = evaluate_fitness!(p, model, lambda_exp, P_exp)
            if fit < swarm.gbest_val
                swarm.gbest_val = fit
                swarm.gbest_pos = copy(p.position)
            end
        end

        if iter % 200 == 0
            @printf("[DYN] Iter %5d | w: %.4f | MSE: %.6e | Param: [%.4f, %.4f, %.4f]\n",
                iter, w, swarm.gbest_val, swarm.gbest_pos[1], swarm.gbest_pos[2], swarm.gbest_pos[3])
        end
        history[iter] = swarm.gbest_val
    end

    if return_history
        return swarm.gbest_pos, swarm.gbest_val, history
    end
    return swarm.gbest_pos, swarm.gbest_val
end

# PSO constriction coeff
function run_pso_constriction(model::HyperelasticModel, lambda_exp::Vector{Float64}, P_exp::Vector{Float64};
    num_particles=30, max_iter=100, dim=3, c1=2.05, c2=2.05, return_history=false)

    phi = c1 + c2
    if phi <= 4.0
        error("phi = c1 + c2 > 4 for constriction PSO")
    end
    chi = 2.0 / abs(2.0 - phi - sqrt(phi^2 - 4.0 * phi))

    swarm = init_swarm(model, lambda_exp, P_exp, num_particles=num_particles, dim=dim)
    history = Vector{Float64}(undef, max_iter)

    for iter in 1:max_iter
        for p in swarm.particles
            r1, r2 = rand(dim), rand(dim)
            p.velocity .= chi .* (
                p.velocity .+
                c1 .* r1 .* (p.pbest_pos .- p.position) .+
                c2 .* r2 .* (swarm.gbest_pos .- p.position)
            )

            p.position .= p.position .+ p.velocity

            fit = evaluate_fitness!(p, model, lambda_exp, P_exp)
            if fit < swarm.gbest_val
                swarm.gbest_val = fit
                swarm.gbest_pos = copy(p.position)
            end
        end

        if iter % 200 == 0
            @printf("[CON] Iter %5d | chi: %.4f | MSE: %.6e | Param: [%.4f, %.4f, %.4f]\n",
                iter, chi, swarm.gbest_val, swarm.gbest_pos[1], swarm.gbest_pos[2], swarm.gbest_pos[3])
        end
        history[iter] = swarm.gbest_val
    end

    if return_history
        return swarm.gbest_pos, swarm.gbest_val, history
    end
    return swarm.gbest_pos, swarm.gbest_val
end

function predict_curve(model::HyperelasticModel, lambdas, params::Vector{Float64})
    return [nominal_stress(model, lam, params) for lam in lambdas]
end

function save_comparison_data(path::String, lambdas::Vector{Float64}, p_exp::Vector{Float64},
    p_std::Vector{Float64}, p_dyn::Vector{Float64}, p_con::Vector{Float64})

    data = hcat(lambdas, p_exp, p_std, p_dyn, p_con)
    open(path, "w") do io
        println(io, "lambda_treloar,P_treloar,P_PSO_standard,P_PSO_dynamic_w,P_PSO_constriction")
        writedlm(io, data, ',')
    end
end

function save_convergence_data(path::String, hist_std::Vector{Float64}, hist_dyn::Vector{Float64}, hist_con::Vector{Float64})
    iters = collect(1:length(hist_std))
    data = hcat(iters, hist_std, hist_dyn, hist_con)
    open(path, "w") do io
        println(io, "iteration,MSE_STD,MSE_DYN,MSE_CON")
        writedlm(io, data, ',')
    end
end

# ==============================================================================
# 5. TEST
# ==============================================================================
# # Tạo Synthetic Data [0.4, 0.05, 0.01]
# true_params = [0.4, 0.05, 0.01]
# lambda_data = collect(1.0:0.1:2.0) # Độ giãn dài từ 1.0 đến 2.0
# P_data = [nominal_stress(Yeoh(), lam, true_params) for lam in lambda_data]
# # Thêm noise
# P_noisy = P_data .+ 0.02 .* randn(length(P_data))
# println("Bắt đầu inverse = sPSO...")
# best_params, best_mse = run_pso(Yeoh(), lambda_data, P_noisy, num_particles=50, max_iter=200)

# println("\n--- RESULT ---")
# @printf("Tham số gốc (ẩn): [0.4000, 0.0500, 0.0100]\n")
# @printf("Tham số PSO tìm:  [%.4f, %.4f, %.4f]\n", best_params[1], best_params[2], best_params[3])
# @printf("Sai số MSE:       %.6e\n", best_mse)

# ==============================================================================
# ------------------ TRELOAR (1944) --------------------------------------------
# Lambda  (Stretch)
lambda_treloar = [1.0, 1.34, 1.70, 2.26, 2.87, 3.48, 4.09, 4.70, 5.32, 5.93, 6.54, 7.15, 7.62]

# Nominal stress - MPa
P_treloar = [0.0, 0.40, 0.60, 0.88, 1.15, 1.45, 1.80, 2.30, 3.10, 4.40, 6.10, 8.20, 10.30]
# ------------------------------------------------------------------------------

# __MAIN__
println("Inverse 3 biến thể PSO...")

best_std, mse_std, hist_std = run_pso(Yeoh(), lambda_treloar, P_treloar, num_particles=100, max_iter=2000, return_history=true)
best_dyn, mse_dyn, hist_dyn = run_pso_dynamic_w(Yeoh(), lambda_treloar, P_treloar, num_particles=100, max_iter=2000, return_history=true)
best_con, mse_con, hist_con = run_pso_constriction(Yeoh(), lambda_treloar, P_treloar, num_particles=100, max_iter=2000, return_history=true)

println("\n--- RESULT: 3 CASES ---")
@printf("[STD] Param: [%.4f, %.4f, %.4f] | MSE: %.6e\n", best_std[1], best_std[2], best_std[3], mse_std)
@printf("[DYN] Param: [%.4f, %.4f, %.4f] | MSE: %.6e\n", best_dyn[1], best_dyn[2], best_dyn[3], mse_dyn)
@printf("[CON] Param: [%.4f, %.4f, %.4f] | MSE: %.6e\n", best_con[1], best_con[2], best_con[3], mse_con)

# Curve
lambda_smooth = collect(range(1.0, stop=8.0, length=100))
P_std_smooth = predict_curve(Yeoh(), lambda_smooth, best_std)
P_dyn_smooth = predict_curve(Yeoh(), lambda_smooth, best_dyn)
P_con_smooth = predict_curve(Yeoh(), lambda_smooth, best_con)

# Data compaare vs Treloar
P_std_treloar = predict_curve(Yeoh(), lambda_treloar, best_std)
P_dyn_treloar = predict_curve(Yeoh(), lambda_treloar, best_dyn)
P_con_treloar = predict_curve(Yeoh(), lambda_treloar, best_con)
save_comparison_data("PSO_Comparison_Data.csv", lambda_treloar, P_treloar, P_std_treloar, P_dyn_treloar, P_con_treloar)
save_convergence_data("PSO_Convergence_Data.csv", hist_std, hist_dyn, hist_con)

# Plot
p_compare = plot(
    title="So sánh 3 biến thể PSO (Yeoh) với Treloar 1944",
    titlefontsize=8,
    xlabel="Độ giãn dài (Stretch Ratio, λ)",
    ylabel="Ứng suất danh định (Nominal Stress, MPa)",
    legend=:topleft,
    legendfontsize=6,
    guidefontsize=6,
    tickfontsize=5,
    grid=true,
    framestyle=:box,
    dpi=300
)

scatter!(p_compare, lambda_treloar, P_treloar,
    label="Treloar (1944)",
    markershape=:circle,
    markercolor=:black,
    markersize=4)

plot!(p_compare, lambda_smooth, P_std_smooth,
    label="PSO chuẩn (w cố định)",
    linewidth=2,
    linecolor=:red)

plot!(p_compare, lambda_smooth, P_dyn_smooth,
    label="PSO quán tính động",
    linewidth=2,
    linecolor=:blue,
    linestyle=:dash)

plot!(p_compare, lambda_smooth, P_con_smooth,
    label="PSO constriction",
    linewidth=2,
    linecolor=:green,
    linestyle=:dot)

display(p_compare)
savefig(p_compare, "PSO_3Cases_Comparison.png")

# Plot hội tụ
iters = collect(1:length(hist_std))
p_conv = plot(
    iters, hist_std,
    title="So sánh tốc độ hội tụ của 3 biến thể PSO",
    titlefontsize=8,
    xlabel="Iteration",
    ylabel="Global Best MSE",
    yscale=:log10,
    label="PSO chuẩn (w cố định)",
    linewidth=2,
    linecolor=:red,
    legend=:topright,
    legendfontsize=6,
    guidefontsize=6,
    tickfontsize=5,
    grid=true,
    framestyle=:box,
    dpi=300
)

plot!(p_conv, iters, hist_dyn,
    label="PSO quán tính động",
    linewidth=2,
    linecolor=:blue,
    linestyle=:dash)

plot!(p_conv, iters, hist_con,
    label="PSO constriction",
    linewidth=2,
    linecolor=:green,
    linestyle=:dot)

display(p_conv)
savefig(p_conv, "PSO_Convergence_Comparison.png")

# Plot Treloar only
p_treloar = scatter(
    lambda_treloar, P_treloar,
    title="Dữ liệu Treloar 1944",
    titlefontsize=8,
    xlabel="Độ giãn dài (Stretch Ratio, λ)",
    ylabel="Ứng suất danh định (Nominal Stress, MPa)",
    label="Thực nghiệm (Treloar, 1944)",
    legend=:topleft,
    legendfontsize=6,
    guidefontsize=6,
    tickfontsize=5,
    markershape=:circle,
    markercolor=:blue,
    markersize=5,
    grid=true,
    framestyle=:box,
    dpi=300
)

display(p_treloar)
savefig(p_treloar, "Treloar_Only.png")