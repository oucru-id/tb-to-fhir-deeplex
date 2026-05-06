#!/usr/bin/env nextflow

nextflow.enable.dsl = 2                          

process UPLOAD_TO_FHIR {
    publishDir "${params.results_dir}/fhir_upload", mode: 'copy'
    debug true

    input:
    path(fhir_file)

    output:
    path "${fhir_file.baseName}.upload.json", emit: upload_result

    script:
    def static_token_arg  = params.fhir_server_auth ? "--static_token '${params.fhir_server_auth}'" : ""
    def auth_url_arg      = params.auth_base_url    ? "--auth_base_url '${params.auth_base_url}'"   : ""
    def client_id_arg     = params.client_id        ? "--client_id '${params.client_id}'"           : ""
    def client_secret_arg = params.client_secret    ? "--client_secret '${params.client_secret}'"   : ""
    def api_key_arg       = params.api_key          ? "--api_key '${params.api_key}'"               : ""
    """
    python3 ${projectDir}/scripts/upload_fhir.py \\
        --fhir_file ${fhir_file} \\
        --fhir_server_url '${params.fhir_server_url}' \\
        ${static_token_arg} \\
        ${auth_url_arg} \\
        ${client_id_arg} \\
        ${client_secret_arg} \\
        ${api_key_arg}
    """
}

workflow UPLOAD_FHIR {
    take:
    fhir_files
    
    main:
    UPLOAD_TO_FHIR(fhir_files)
    
    emit:
    results = UPLOAD_TO_FHIR.out.upload_result
}
