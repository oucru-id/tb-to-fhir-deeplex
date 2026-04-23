#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

log.info """
    Mycobacterium tuberculosis Mutation Analysis Mini Pipeline (v${params.version})
    Deeplex Excel Conversion to FHIR Genomics
    Developed by SPHERES-OUCRU ID
    Documentation: https://docs.google.com/document/d/1loZhheM22cWnU3taqAaef16lePK7BoNJ5lTjEuXwFYE/edit?usp=sharing
"""

include { UPLOAD_FHIR }           from './workflows/upload_fhir.nf'
include { VERSIONS }              from './workflows/utils.nf'
include { DEEPLEX }               from './workflows/deeplex.nf'

workflow {
    deeplex_ch = Channel
        .fromPath("${params.deeplex_dir}/*.xlsx", checkIfExists: false)
        .filter { file -> !file.name.startsWith('~$') }

    deeplex_out = DEEPLEX(deeplex_ch)

    upload_out = UPLOAD_FHIR(deeplex_out.fhir_output)

    VERSIONS()
}
