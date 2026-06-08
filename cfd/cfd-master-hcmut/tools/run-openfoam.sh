#!/bin/sh
set -e # Not setting -u as it gets triggered by the OpenFOAM RunFunctions

# Prepare an (intentionally empty) .foam file for the ParaView OpenFOAM reader
CASENAME="$(pwd | xargs basename)"
touch "$CASENAME.foam"

# OpenFOAM run functions: getApplication, getNumberOfProcessors
# shellcheck disable=SC1090 # This is an OpenFOAM file which we don't need to check
. "${WM_PROJECT_DIR}/bin/tools/RunFunctions"
solver=$(getApplication)
if [ "${1:-}" = "-parallel" ]; then
    procs=$(getNumberOfProcessors)
    decomposePar -force
    # OpenFOAM here is built with OpenMPI; avoid Conda MPICH mpirun from PATH.
    MPI_LAUNCHER="/usr/bin/mpirun"
    if [ ! -x "${MPI_LAUNCHER}" ]; then
        MPI_LAUNCHER="$(command -v mpirun)"
    fi
    "${MPI_LAUNCHER}" -np "${procs}" "${solver}" -parallel
    reconstructPar
else
    ${solver}
fi
