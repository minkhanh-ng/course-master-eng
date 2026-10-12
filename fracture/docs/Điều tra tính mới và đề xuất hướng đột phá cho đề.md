# **Báo cáo Phân tích Tính mới và Đề xuất Đột phá Kiến trúc Toán tử Thần kinh cho Mô hình Đứt gãy Từ biến Phase-Field của Thép P91**

## **Tóm tắt Tổng quan**

Báo cáo này trình bày kết quả phân tích học thuật chuyên sâu và đánh giá tính mới đối với dự án nghiên cứu mô hình hóa đứt gãy từ biến phase-field (creep-phase-field fracture) áp dụng cho vật liệu thép P91. Đánh giá được thực hiện thông qua việc đối chiếu trực tiếp giữa khung nghiên cứu nền tảng đề xuất ban đầu — sử dụng Phương pháp Năng lượng Sâu (Deep Energy Method \- DEM) kết hợp mạng Kolmogorov-Arnold (KAN) và ChebyKAN để khảo sát sức kháng nứt không gian (spatial fracture resistance) — với bức tranh toàn cảnh của các công bố khoa học quốc tế tính đến cuối năm 2026\. Quá trình điều tra đã phát hiện ra những điểm nghẽn nghiêm trọng về tính đột phá thuật toán, đặc biệt là sự xuất hiện của các công trình đã giải quyết trọn vẹn bài toán ChebyKAN-DEM cho vật liệu bất đồng nhất. Dựa trên phân tích rủi ro hệ thống và việc định vị các khoảng trống tri thức thực thụ trong lĩnh vực cơ học vật liệu và học máy khoa học (Scientific Machine Learning \- SciML), báo cáo này đề xuất một sự chuyển hướng mang tính cấu trúc: loại bỏ phương pháp DEM truyền thống và thiết lập **Khung Toán tử Thần kinh KANO-GNN Nhất quán Nhiệt động lực học (Thermodynamically Consistent KANO-GNN) nhằm mô phỏng và dự đoán thời gian thực đứt gãy từ biến Type IV trong mối hàn đa vùng của thép P91**.

## **1\. Phân tích Khung Nghiên cứu Nền tảng (Baseline Framework Analysis)**

Để định vị chính xác tính mới của đề tài, bước đầu tiên đòi hỏi sự phân tích tường tận về khung lý thuyết và phương pháp luận của định hướng nghiên cứu xuất phát. Khung nghiên cứu này được xây dựng dựa trên nền tảng cơ học của Ragab et al. (2024), sử dụng môi trường tính toán FEniCSx để giải quyết bài toán đứt gãy từ biến của thép P91 ở điều kiện nhiệt độ cao (650 °C).

### **1.1. Nền tảng Cơ học Từ biến và Đứt gãy Phase-Field**

Mô hình vật lý cốt lõi tích hợp ba thành phần cơ bản nhằm mô tả hành vi phân rã cấu trúc vật liệu dưới tác động của nhiệt độ và tải trọng dài hạn. Thành phần thứ nhất là luật từ biến Norton chi phối biến dạng từ biến J2, kết hợp chặt chẽ với mô hình cạn kiệt độ dẻo (ductility exhaustion) Cocks-Ashby để định lượng sự tiến hóa của độ hư hỏng từ biến (creep damage, D). Thành phần thứ hai là phương pháp phase-field dựa trên xấp xỉ Ambrosio-Tortorelli thứ hai (AT2). Phương pháp này loại bỏ nhu cầu theo dõi bề mặt nứt rời rạc phức tạp bằng cách đưa ra một trường biến liên tục d(x) \\in \[0,1\], trong đó giá trị 0 đại diện cho vật liệu nguyên vẹn và 1 biểu thị trạng thái đứt gãy hoàn toàn, với quá trình chuyển đổi được điều chuẩn bởi tham số chiều dài \\ell.  
Sự ghép cặp đa vật lý (multiphysics coupling) giữa từ biến và đứt gãy được thực hiện thông qua một hàm năng lượng thúc đẩy (driving force) và sự suy giảm của độ dẻo dai phá hủy. Cụ thể, năng lượng đàn hồi và công tiêu tán không đàn hồi (công dẻo và công từ biến) được tích lũy vào một trường lịch sử \\mathcal{H} \= \\max\_{\\tau \\le t} (\\Psi\_e \+ W\_p \+ W\_{cr}) nhằm duy trì tính bất thuận nghịch của quá trình nứt. Song song đó, sức kháng nứt hiệu dụng \\mathcal{G}\_{eff}(x) không còn là một hằng số mà bị suy giảm trực tiếp bởi trường hư hỏng từ biến D(x), tạo ra một bài toán đứt gãy với độ dẻo dai biến thiên theo không gian và thời gian.

### **1.2. Mở rộng Học Máy qua Phương pháp Năng lượng Sâu (DEM)**

Nhận thấy những giới hạn về chi phí tính toán của phương pháp phần tử hữu hạn (FEM) khi giải quyết các hệ phương trình ghép cặp phi tuyến tính cao, đề cương ban đầu đề xuất ứng dụng Học Máy thông qua Phương pháp Năng lượng Sâu (DEM). Thay vì rời rạc hóa không gian bằng lưới (meshing), DEM biểu diễn các trường chuyển vị và trường phase-field bằng các mạng nơ-ron nhân tạo và tối ưu hóa trọng số mạng nhằm đạt cực tiểu phiếm hàm năng lượng tổng của hệ thống.  
Hai nhánh nghiên cứu mở rộng được thiết lập trên nền tảng DEM này bao gồm R1 và R2. Nhánh R1 tập trung vào bài toán chuyển đổi độ dẻo đa trục, giải quyết bài toán ngược để hiệu chuẩn các tham số độ dẻo giữa các mức độ ràng buộc đỉnh nứt (crack-tip constraint) khác nhau. Tuy nhiên, nhánh R2 được xác định là hướng đi chủ đạo, sử dụng DEM để khám phá không gian hàm của sức kháng nứt không gian \\mathcal{G}\_{eff}(x). Mục tiêu trung tâm của R2 là định lượng ngưỡng sai số khi loại bỏ thành phần gradient của \\mathcal{G}\_{eff} thông qua chỉ số \\chi \= \\ell \\vert{}\\nabla \\ln \\mathcal{G}\\vert{}, từ đó xác định tính hợp lệ của việc sử dụng dạng Laplacian chuẩn hóa thay vì dạng biến phân thuần túy trong phương trình phase-field. Đích đến cuối cùng là tích hợp cấu trúc mạng ChebyKAN nhằm xử lý hiệu quả các gradient sắc nét, tạo tiền đề xây dựng một bản sao số ảo (virtual digital twin) dự đoán tuổi thọ cho bình chịu áp lực P91 mà không cần phụ thuộc vào dữ liệu cảm biến thời gian thực.

## **2\. Điều tra Tính mới và Toàn cảnh Học thuật (Exhaustive Novelty Investigation)**

Để thẩm định tiềm năng công bố khoa học của khung nghiên cứu nền tảng, một cuộc điều tra toàn diện đã được thực hiện trên các cơ sở dữ liệu học thuật quốc tế tính đến năm 2026\. Phân tích này tập trung vào các giao điểm của Phương pháp Năng lượng Sâu (DEM), kiến trúc KAN/ChebyKAN, mô hình hóa bất đồng nhất (heterogeneity), đứt gãy từ biến, và ứng dụng của Mạng Nơ-ron Đồ thị (GNN) cùng Toán tử Thần kinh (Neural Operators).

### **2.1. Tình trạng Bão hòa của Phương pháp Năng lượng Sâu (DEM) trong Cơ học Đứt gãy**

Phương pháp DEM đã chứng minh được năng lực to lớn trong việc giải các phương trình đạo hàm riêng (PDE) trong cơ học vật rắn. Sự dịch chuyển từ cơ học đàn hồi tuyến tính sang siêu đàn hồi biến dạng lớn đã được khai phá rộng rãi. Đối với các hệ thống tiêu tán năng lượng phức tạp hơn, các kiến trúc Mạng Nơ-ron Vật lý (PINNs) dựa trên năng lượng cũng đã được áp dụng thành công để mô hình hóa hiện tượng từ biến (creep), chùng ứng suất, và các hành vi đàn-nhớt-dẻo (elasto-viscoplastic).  
Trong bối cảnh đứt gãy phase-field, việc sử dụng DEM để tối thiểu hóa phiếm hàm Ambrosio-Tortorelli đã trở thành một chủ đề nghiên cứu rất phổ biến trong giai đoạn 2022-2025. Các thách thức kỹ thuật cốt lõi như tính bất thuận nghịch (irreversibility) của vết nứt, phụ thuộc lịch sử (path-dependence), và sự phân rã năng lượng (energy split) để tránh nứt do nén đều đã được giải quyết thông qua việc lưu trữ trường lịch sử cục bộ, cập nhật giả thời gian (pseudo-time stepping), hoặc sử dụng các cơ chế cổng trong mạng nơ-ron hồi quy (GRU). Do đó, việc chỉ đơn thuần áp dụng DEM cho mô hình từ biến-phase-field mang lại rủi ro cao về mặt tính mới, dễ bị hội đồng phản biện đánh giá là một sự ghép nối phương pháp (incremental novelty) thay vì một đột phá cơ bản về lý thuyết.

### **2.2. Điểm Nghẽn Chí mạng về Tính mới của ChebyKAN-DEM**

Điểm tựa tính mới lớn nhất của định hướng ban đầu là việc sử dụng kiến trúc KAN (Kolmogorov-Arnold Network), cụ thể là ChebyKAN, để tăng cường khả năng hội tụ của DEM tại các vùng có gradient trường phase-field sắc nét. Khác với Multilayer Perceptron (MLP) truyền thống dựa trên Định lý Xấp xỉ Phổ quát (Universal Approximation Theorem) với các hàm kích hoạt tĩnh tại nút, mạng KAN đưa các hàm kích hoạt có thể học được lên các cạnh (edges) của mạng. Biến thể ChebyKAN tận dụng tính trực giao của đa thức Chebyshev để gia tăng độ ổn định số học và giảm thiểu hiệu ứng Runge so với các hàm B-spline thông thường.  
Tuy nhiên, kết quả rà soát học thuật năm 2026 đã bộc lộ một rào cản mang tính hủy diệt đối với tính mới của hướng đi này. Công trình nghiên cứu với tiêu đề *"ChebyKAN-Enhanced Deep Energy Method for Phase Field Fracture: From Homogeneous to Heterogeneous Materials"* đã được xuất bản chính thức bởi nhóm tác giả Peng Zhang, Keke Tang, và Bai-Xiang Xu. Bài báo này đã thiết lập kiến trúc toán học hoàn chỉnh cho việc ứng dụng ChebyKAN trong DEM, và đặc biệt hơn, đã trực tiếp sử dụng nó để giải quyết bài toán đứt gãy phase-field trong **vật liệu bất đồng nhất (heterogeneous materials)**.  
Hệ quả của công bố này là toàn bộ cấu trúc thuật toán dự kiến của nhánh R2 đã bị chiếm lĩnh. Việc cố gắng giữ nguyên kiến trúc ChebyKAN-DEM và chỉ thay đổi đối tượng nghiên cứu (thêm từ biến, chuyển sang vật liệu P91) sẽ không thể vượt qua hàng rào phản biện của các tạp chí hạng Q1. Sự trùng lặp quá lớn về kiến trúc mạng và phương pháp xử lý bất đồng nhất khiến cho tính mới thuật toán rơi xuống mức cực thấp.

### **2.3. Bất đồng nhất trong Cơ học Phase-Field và Hiện thực Luyện kim của Thép P91**

Trong bài toán R2 ban đầu, việc thiết lập chỉ số \\chi \= \\ell \\vert{}\\nabla \\ln \\mathcal{G}\\vert{} nhằm đánh giá khi nào có thể loại bỏ gradient của sức kháng nứt mang ý nghĩa về mặt toán học. Dẫu vậy, các phân tích về sự xấp xỉ của vết nứt qua các vùng giao diện (interfaces) hoặc môi trường có độ dẻo dai thay đổi liên tục đã được các học giả như Yoshioka, Mollaali, Kolditz, và Hansen-Dörr đào sâu một cách tường tận. Các công trình này đã giải quyết triệt để tính hội tụ của phiếm hàm phase-field khi độ dẻo dai phá hủy \\mathcal{G}\_c(x) biến thiên theo không gian, bao gồm cả các đánh giá giải tích trên mô hình 1D và các mô phỏng 2D phức tạp.  
Quan trọng hơn, khi đặt trong bối cảnh kỹ thuật công nghiệp của thép P91, việc giả định một trường gradient sức kháng nứt ngẫu nhiên hoặc trơn tru mang tính lý thuyết cao lại xa rời bản chất vật lý của vật liệu. Thép mactenxit P91 được ứng dụng rộng rãi trong các hệ thống đường ống hơi áp suất cao, nơi sự cố đứt gãy từ biến xảy ra không phải ở dạng đồng nhất, mà chủ yếu tập trung dưới hình thức **nứt Type IV (Type IV cracking)**. Hiện tượng nứt Type IV diễn ra khu trú tại Vùng Ảnh hưởng Nhiệt hạt mịn (Fine-Grained Heat-Affected Zone \- FGHAZ) của mối hàn, một dải vi cấu trúc cực hẹp nơi chu trình hàn đã làm hòa tan một phần các hạt kết tủa và thúc đẩy sự thô hóa nhanh chóng của pha Laves và pha Z trong quá trình vận hành.  
Sự biến thiên vi cấu trúc này gây ra một dải suy giảm độ bền từ biến nghiêm trọng, khiến quá trình tích lũy hư hỏng (creep void nucleation) và truyền nứt diễn ra khốc liệt tại FGHAZ ngay cả dưới mức ứng suất thấp. Do đó, bất đồng nhất của P91 là một **bất đồng nhất cấu trúc đa vùng (macro-zone structural heterogeneity)** với các ranh giới rõ ràng giữa Kim loại cơ bản (Base Metal), HAZ, và Kim loại hàn (Weld Metal). Việc mô hình hóa sức kháng nứt không gian mà không phản ánh được tính phi tuyến cục bộ của các vùng luyện kim này sẽ bị giới chuyên môn đánh giá là thiếu tính thực tiễn và không đóng góp được cho ngành cơ học vật liệu.

### **2.4. Sự trỗi dậy của Toán tử Thần kinh (Neural Operators) và Mạng Đồ thị (GNN)**

Mục tiêu xa hạn của dự án nền tảng là xây dựng một bản sao số ảo (Virtual Digital Twin) cho bình chịu áp lực. Bản sao số yêu cầu khả năng giải quyết các phép toán tiến tới (forward queries) theo thời gian thực để phản hồi với các kịch bản tải trọng hoặc sự thay đổi hình học liên tục. Tại đây, DEM bộc lộ một hạn chế mang tính nguyên lý: nó là một phương pháp giải (solver) chứ không phải là một mô hình thay thế (surrogate) có khả năng khái quát hóa. Mỗi khi điều kiện biên hoặc hình học thay đổi, toàn bộ mạng nơ-ron của DEM phải được huấn luyện lại thông qua quá trình tối ưu hóa hàm tổn thất năng lượng, một quá trình chậm chạp không kém gì FEM truyền thống.  
Để vượt qua khoảng trống khái quát hóa (generalization gap) này, lĩnh vực SciML đã chuyển hướng mạnh mẽ sang các Toán tử Thần kinh (Neural Operators) như DeepONet và Fourier Neural Operator (FNO), vốn có khả năng học ánh xạ trực tiếp từ không gian thông số/không gian hàm đầu vào sang không gian hàm nghiệm. Tuy nhiên, FNO thường gặp phải "tắc nghẽn phổ" (spectral bottleneck) do việc cắt cụt các chế độ tần số cao, khiến nó gặp khó khăn khi mô phỏng các gián đoạn biến dạng lớn hoặc đường nứt phase-field sắc nét.  
Giải pháp đột phá xuất hiện vào giai đoạn 2025-2026 chính là **Kolmogorov-Arnold Neural Operator (KANO)**. KANO duy trì cấu trúc học toán tử nhưng kết hợp khả năng thu thập thông tin tần số thấp của biến đổi Fourier với năng lực xấp xỉ không gian cục bộ cực tốt của mạng KAN, cho phép bảo toàn các gradient độ dốc cao của vết nứt mà không cần mô hình mạng quá lớn.  
Song song đó, để truyền tải thông tin hình học phức tạp của các vùng vi cấu trúc (như mối hàn P91), Mạng Nơ-ron Đồ thị (Graph Neural Networks \- GNN) nổi lên như một chuẩn mực. GNN có khả năng xử lý lưới phi cấu trúc (unstructured mesh) và mô hình hóa trực tiếp sự truyền thông điệp ứng suất/hư hỏng qua các ranh giới vật liệu bất đồng nhất. Sự giao thoa giữa KANO và GNN đại diện cho giới hạn tối tân (state-of-the-art) trong mô phỏng vật lý đa quy mô hiện nay.

### **Bảng 1: Phân tích Rủi ro và Đánh giá Tính mới của Khung Nền tảng**

| Yếu tố Khảo sát | Hiện trạng Khung Nền tảng (Baseline) | Phát hiện từ Điều tra Học thuật (2026) | Mức độ Rủi ro & Kết luận |
| :---- | :---- | :---- | :---- |
| **Phương pháp Lõi** | Tối thiểu hóa năng lượng bằng DEM | Đã ứng dụng rộng rãi cho siêu đàn hồi, dẻo và nứt giòn. | **Cao**. Thiếu sức nặng lý thuyết, chỉ mang tính kỹ thuật. |
| **Kiến trúc Mạng** | Tăng cường học gradient bằng ChebyKAN | Đã bị Zhang et al. (2026) công bố với tên gọi và ứng dụng trùng khớp (ChebyKAN-DEM cho nứt bất đồng nhất). | **Cực cao**. Vi phạm tính mới thuật toán cốt lõi, chắc chắn bị hội đồng phản biện từ chối. |
| **Độ dẻo dai Không gian** | Đánh giá toán học gradient \\mathcal{G}\_{eff} | Hansen-Dörr, Yoshioka đã chứng minh các mô hình hội tụ năng lượng tương tự. | **Trung bình-Cao**. Rủi ro bị coi là một nghiên cứu lặp lại (re-invention) trong cơ học đứt gãy. |
| **Bản chất Thép P91** | Xem vật liệu là một khối với nhiễu ngẫu nhiên | Yếu điểm sinh tử của P91 là nứt Type IV tại vi cấu trúc FGHAZ của mối hàn. | **Cao**. Bỏ qua bài toán công nghiệp cấp bách nhất của P91, mất tính kết nối luyện kim. |
| **Khả năng Bản sao số** | Dùng DEM làm forward model | DEM không có khả năng ngoại suy (generalize) tức thì, cần quá trình re-training chậm chạp. | **Cao**. Lỗi sai về mặt kiến trúc hệ thống khi định nghĩa bản sao số thời gian thực. |

## **3\. Đề xuất Sửa đổi Táo bạo: Định hướng Nghiên cứu Đột phá**

Dựa trên sự phân tích toàn diện các lỗ hổng của định hướng cũ và nắm bắt các khoảng trống tri thức đắt giá nhất trong cả hai lĩnh vực (Cơ học Đứt gãy Luyện kim và Học máy Khoa học), báo cáo này đề xuất loại bỏ hoàn toàn phương pháp DEM và nhánh R2 cũ. Thay vào đó, một khung nghiên cứu hệ thống mang tính đột phá được thiết lập, hướng trực tiếp đến bài toán Nứt Type IV của thép P91 với cấu trúc Mạng Toán tử tân tiến nhất.

### **3.1. Tiêu đề Định hướng Nghiên cứu Đề xuất**

**"A Thermodynamically Consistent KANO-GNN Operator for Modeling Type IV Creep-Phase-Field Fracture in Heterogeneous P91 Weldments towards Virtual Digital Twins"** *(Toán tử KANO-GNN Nhất quán Nhiệt động lực học trong Mô hình hóa Đứt gãy Phase-field Từ biến Type IV cho Mối hàn P91 Bất đồng nhất hướng tới Bản sao số Ảo)*

### **3.2. Triết lý Thiết kế và Các Trụ cột Cấu trúc**

Khung nghiên cứu đề xuất dịch chuyển bản chất của hệ thống từ một công cụ giải (solver) sang một Toán tử Thay thế (Operator Surrogate) với tốc độ mô phỏng tiệm cận thời gian thực (real-time). Hệ thống bao gồm ba trụ cột đột phá:

#### **Trụ cột 1: Chuyển đổi Cơ học Rời rạc sang Đồ thị (Graph-encoded Microstructure)**

Để giải quyết bài toán bất đồng nhất một cách có ý nghĩa vật lý, hình học của bình chịu áp lực P91 sẽ không bị mô hình hóa một cách ngẫu nhiên. Thay vào đó, khu vực mối hàn được phân rã rõ rệt thành Kim loại cơ bản (BM), Vùng ảnh hưởng nhiệt (HAZ \- bao gồm coarse-grained và fine-grained), và Kim loại hàn (WM). Miền không gian liên tục \\Omega được biểu diễn thành đồ thị không gian vô hướng \\mathbb{G} \= (\\mathbb{V}, \\mathbb{E}) thông qua một mạng **Graph Neural Network (GNN)**.

> * **Đặc trưng Nút (Node Features) v\_i:** Mã hóa loại vi cấu trúc (BM, HAZ, WM) cùng với các hằng số vật liệu nội tại như hệ số từ biến A\_i, n\_i, độ dẻo cạn kiệt \\varepsilon\_{fi}, và năng lượng phá hủy G\_{c0i}.  
> * **Đặc trưng Cạnh (Edge Features) e\_{ij}:** Chứa khoảng cách vật lý và liên kết lưới học được, cho phép mạng truyền thông điệp ứng suất (message passing) tập trung vào các ranh giới vi cấu trúc nơi chênh lệch độ cứng tạo ra ứng suất cục bộ (local triaxiality). Việc dùng GNN làm bộ mã hóa (Encoder) đảm bảo vật lý luyện kim được nhúng trực tiếp vào dữ liệu học máy.

#### **Trụ cột 2: Lõi Học Toán tử KANO (Kolmogorov-Arnold Neural Operator)**

Trái tim của hệ thống dự đoán không còn là DEM tối thiểu hóa năng lượng tĩnh, mà là kiến trúc **KANO** làm nhiệm vụ học ánh xạ lịch sử thời gian. Trường tiềm ẩn Z\_0(x) được chiết xuất từ GNN, kết hợp với các biến trạng thái tại thời điểm t\_n bao gồm chuyển vị u\_n, ứng suất \\sigma\_n, hư hỏng từ biến D\_n, phase-field d\_n, và trường lịch sử cơ học \\mathcal{H}\_n. Toán tử KANO sẽ thực hiện phép chiếu không gian biến trạng thái này sang một chiều tiềm ẩn, áp dụng chuỗi biến đổi tích hợp cả cơ sở phổ (Fourier) và cơ sở không gian (residual KAN). Phương trình toán tử của KANO có dạng:  
\\mathcal{K}\_{\\text{KANO}} (v) \= \\mathcal{F}^{-1} \\left( \\text{KAN}\_{\\theta} (\\mathcal{F}(v)) \\right) \+ \\text{KAN}\_{\\phi}(v)  
Trong đó, \\mathcal{F} biểu thị phép biến đổi Fourier, giúp nắm bắt động lực học từ biến toàn cục (global creep relaxation), trong khi mạng KAN phi tuyến \\text{KAN}\_{\\phi} giữ lại các gradient độ dốc cao của trường hư hỏng D(x) và vết nứt d(x) hẹp tại vùng HAZ. KANO có thể giải quyết các điểm mù tần số cao mà FNO thường mắc phải, đồng thời cung cấp dự đoán bước thời gian t\_{n+1} chỉ trong vài mili-giây, đáp ứng tiêu chuẩn của một bản sao số.

#### **Trụ cột 3: Huấn luyện Nhất quán Nhiệt động lực học (Thermodynamically Consistent Loss)**

Các mô hình Học máy dựa trên dữ liệu (Data-driven) thường sinh ra các dự đoán phản vật lý, đặc biệt là trong cơ học hư hỏng nơi tính bất thuận nghịch (irreversibility) là quy luật thép: vết nứt không thể lành lại, và hư hỏng từ biến không thể giảm sút. Để khắc phục, một hàm suy hao (loss function) đa mục tiêu được đề xuất, kết hợp Bất đẳng thức Tiêu tán (Dissipation Inequality) của nhiệt động lực học:  
\\mathcal{L}\_{\\text{total}} \= \\lambda\_{\\text{data}} \\mathcal{L}\_{\\text{data}} \+ \\lambda\_{\\text{PDE}} \\mathcal{L}\_{\\text{PDE}} \+ \\lambda\_{\\text{thermo}} \\mathcal{L}\_{\\text{thermo}}  
Thành phần \\mathcal{L}\_{\\text{thermo}} phạt khắt khe các vi phạm nguyên lý vật lý bằng các hàm kích hoạt bất đối xứng (như ReLU): \$\$ \\mathcal{L}*{\\text{thermo}} \= \\vert{} \\vert{} \\text{ReLU}(d\_n \- \\hat{d}*{n+1}) \\vert{}\\vert{}^2 \+ \\vert{} \\vert{} \\text{ReLU}(D\_n \- \\hat{D}\_{n+1}) \\vert{}\\vert{}^2 \$\$ Việc ép buộc quy luật tiêu tán năng lượng này đóng vai trò như một bộ tinh chỉnh (physics-guided regularizer), đảm bảo KANO-GNN mô phỏng độ tin cậy trong các kịch bản duy trì tải (load-hold) kéo dài hàng nghìn giờ của thiết bị chịu áp lực.

### **Bảng 2: So sánh Kiến trúc Học Máy trong Cơ học Đứt gãy Từ biến**

| Tiêu chí | Phương pháp Năng lượng Sâu (DEM) | Toán tử Fourier (FNO) | Khung Đề xuất KANO-GNN |
| :---- | :---- | :---- | :---- |
| **Bản chất Mô hình** | Bộ giải thuận (Forward Solver). | Toán tử thay thế (Surrogate Operator). | Mạng biểu diễn vi cấu trúc kết hợp Toán tử thay thế. |
| **Xử lý Hình học / Lưới** | Yêu cầu lấy mẫu collocation, khó mô tả miền ghép phức tạp. | Bị giới hạn bởi lưới cấu trúc (structured grid), khó biểu diễn ranh giới HAZ. | Hoàn hảo cho lưới phi cấu trúc, GNN mã hóa trực tiếp mạng lưới ranh giới vật liệu. |
| **Khả năng nắm bắt Vết nứt sắc nét** | Tốt, nhưng hội tụ chậm và phụ thuộc kích thước batch size. | Kém (Spectral Bottleneck), làm nhòe vết nứt do cắt bỏ tần số cao. | Xuất sắc, KANO dùng nhánh không gian KAN để xử lý biên sắc nét của trường phase-field. |
| **Khái quát hóa (Bản sao số)** | Không có. Phải chạy lại tối ưu cho mọi cấu hình mới. | Tốt, xử lý many-query nhanh. | Rất tốt. Ngoại suy được cả cho các hình học đồ thị và biến thiên độ bền từ biến mới. |

## **4\. Lộ trình Triển khai Tổng thể (Implementation Roadmap)**

Việc phát triển và kiểm chứng khung KANO-GNN Nhất quán Nhiệt động lực học sẽ được thực hiện thông qua một quy trình ba giai đoạn nghiêm ngặt, đảm bảo tính liên kết từ vật lý tính toán sang học máy ứng dụng.

### **Giai đoạn 1: Sinh dữ liệu Độ chính xác cao (High-Fidelity Data Generation)**

> * Sử dụng trình giải FEniCSx với công thức biến phân phase-field theo mô hình Ragab et al. (2024) để tạo lập tập dữ liệu cơ sở (Ground Truth).  
> * Thiết lập mô phỏng mặt cắt 2D của bình chịu áp lực hoặc đường ống P91 có chứa vùng hàn.  
> * Thực hiện phương pháp lấy mẫu siêu lập phương Latin (Latin Hypercube Sampling) để thay đổi ngẫu nhiên tải trọng áp suất trong (internal pressure), bề rộng vùng FGHAZ, và nhiệt độ hoạt động. Khởi chạy hàng nghìn mô phỏng song song (FEM runs) để lưu trữ bộ dữ liệu chuỗi thời gian của các biến trạng thái U(x,t).

### **Giai đoạn 2: Huấn luyện và Xác thực KANO-GNN**

> * Ánh xạ toàn bộ cấu trúc lưới phần tử hữu hạn của các mô phỏng FEniCSx sang đồ thị không gian. Khởi tạo trọng số cho bộ mã hóa GNN và lõi toán tử KANO.  
> * Tiến hành quá trình huấn luyện sử dụng các thuật toán tối ưu hóa (như Adam kết hợp L-BFGS) với hàm suy hao đa mục tiêu đã định nghĩa.  
> * Đánh giá chéo (cross-validation) trên các kịch bản nứt Type IV chưa từng thấy (unseen configurations) để kiểm chứng khả năng ngoại suy hình học của GNN và năng lực xấp xỉ phổ của KANO. Các phép thử sẽ đo lường RMSE (Root Mean Square Error) của chuyển vị CMOD, chiều dài vết nứt a(t), và đặc biệt là độ lệch chuẩn về năng lượng tiêu tán.

### **Giai đoạn 3: Triển khai Bản sao số Ảo (Virtual DT Deployment)**

> * Tích hợp KANO-GNN đã được huấn luyện vào hệ thống giám sát thời gian thực.  
> * Định nghĩa của "Bản sao số Ảo" tại đây được thực thi trọn vẹn: hệ thống tiếp nhận các chuỗi tải trọng giả lập theo thời gian và ngay lập tức (trong mili-giây) phóng chiếu (rollout) toàn bộ lịch sử tiến hóa của hư hỏng từ biến và đường nứt phase-field.  
> * Chứng minh hệ thống có thể dự báo chính xác Remaining Useful Life (RUL) của các thành phần P91 mà không cần phụ thuộc vào cảm biến vật lý đặt tại hiện trường, mở ra tiềm năng lớn cho công tác đánh giá an toàn công nghiệp không phá hủy.

## **5\. Kết luận (Conclusions)**

Nghiên cứu đánh giá hệ thống về tính mới và bối cảnh học thuật đã bộc lộ những rủi ro sinh tử của định hướng ban đầu. Việc sử dụng Phương pháp Năng lượng Sâu (DEM) tăng cường bởi ChebyKAN để khảo sát đứt gãy phase-field với sức kháng nứt không gian đã bị chiếm lĩnh bởi các công bố khoa học trong đầu năm 2026\. Hơn nữa, việc chỉ xem xét bất đồng nhất như một hàm toán học ngẫu nhiên đã làm mất đi sự kết nối quan trọng với cơ chế phá hủy thực tế của thép P91 — hiện tượng nứt Type IV tại vùng ảnh hưởng nhiệt của mối hàn.  
Đề xuất chuyển đổi sang **Kiến trúc Toán tử Thần kinh KANO-GNN Nhất quán Nhiệt động lực học** không chỉ né tránh được sự trùng lặp học thuật mà còn tạo ra một cú hích đột phá cho lĩnh vực cơ học tính toán. Khung phương pháp mới mang lại sức mạnh mô phỏng ba chiều kích: (1) Mạng GNN nắm bắt hoàn hảo tính bất đồng nhất đa vùng của vi cấu trúc luyện kim, (2) Lõi KANO giải quyết bài toán tắc nghẽn phổ và ánh xạ trực tiếp động học từ biến-phá hủy, vượt qua sự chậm chạp của DEM, và (3) Nguyên lý nhiệt động lực học đảm bảo độ tin cậy vật lý tuyệt đối của mô hình Học máy. Việc theo đuổi hướng đi này đặt nhóm nghiên cứu vào vị thế tiên phong toàn cầu trong việc phát triển Bản sao số dựa trên nền tảng SciML cho cấu trúc vật liệu hoạt động ở nhiệt độ cao, hứa hẹn mang lại các công bố khoa học có chỉ số ảnh hưởng vượt trội.