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
    """
    #!/bin/bash

    if [ -n "${params.fhir_server_auth}" ]; then
        RESPONSE=\$(curl -s -w "\\n%{http_code}" -X POST \\
            -H "Content-Type: application/fhir+json" \\
            -H "Authorization: Bearer ${params.fhir_server_auth}" \\
            -d @${fhir_file} \\
            "${params.fhir_server_url}")
    else
        RESPONSE=\$(curl -s -w "\\n%{http_code}" -X POST \\
            -H "Content-Type: application/fhir+json" \\
            -d @${fhir_file} \\
            "${params.fhir_server_url}")
    fi

    HTTP_STATUS=\$(echo "\$RESPONSE" | tail -n1)
    RESPONSE_BODY=\$(echo "\$RESPONSE" | sed '\$d')

    echo '{
      "status": "'"\$([ "\$HTTP_STATUS" -ge 200 ] && [ "\$HTTP_STATUS" -lt 300 ] && echo "success" || echo "failed")"'",
      "http_status": '\$HTTP_STATUS',
      "file": "'${fhir_file}'",
      "timestamp": "'"\$(date -Iseconds)"'",
      "server": "'${params.fhir_server_url}'",
      "response": '\$(echo "\$RESPONSE_BODY" | sed 's/^/    /')'
    }' > ${fhir_file.baseName}.upload.json

    echo "Upload completed with status \$HTTP_STATUS"
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
