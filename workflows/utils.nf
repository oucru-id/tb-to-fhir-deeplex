nextflow.enable.dsl = 2

process VERSIONS {
    publishDir "${params.results_dir}", mode: 'copy'

    output:
    path "software_version.yml"

    script:
    """
    echo "pipeline:" > software_version.yml
    echo "  name: tb_mutation_analysis_deeplex" >> software_version.yml
    echo "  description: Deeplex module" >> software_version.yml
    echo "  URL: https://github.com/oucru-id/tb-to-fhir-deeplex" >> software_version.yml
    echo "  version: ${params.version}" >> software_version.yml
    echo "  nextflow: $nextflow.version" >> software_version.yml
    
    echo "databases:" >> software_version.yml
    echo "  reference: \$(basename ${params.reference})" >> software_version.yml
    
    export BASE_DIR="${baseDir}"
    python3 $baseDir/scripts/get_versions.py >> software_version.yml
    """
}
