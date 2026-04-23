# TB to FHIR Genomics Deeplex Excel Pipeline

A Nextflow pipeline for converting Mycobacterium tuberculosis Deeplex Myc-TB Excel genomic data to FHIR Genomics format.

## Overview

This pipeline processes TB genomic data from:
- **Deeplex Excel files**: Post-analysis TB mutation data from the Deeplex platform

## Requirements

### System Dependencies

- **Nextflow** ≥ 20.10.0
- **Java** 11+
- **Python** 3.8+

## Installation

From the repo
```bash
git clone https://github.com/oucru-id/tb-to-fhir-deeplex.git
cd tb-to-fhir-deeplex
```
Docker installation
```bash
docker pull ghcr.io/javiadividya/tb-to-fhir-mini:1.0
```

## Directory Structure

```
tb-to-fhir-deeplex
├── main.nf                          # Main workflow
├── nextflow.config                  # Configuration
├── workflows/
│   ├── deeplex.nf                   # Deeplex processing
│   └── utils.nf                     # Utility functions
├── scripts/
│   ├── xlsx_json_converter.py       # Deeplex to FHIR converter
│   ├── merge_clinical_deeplex.py    # DiagnosticReport data merge
│   └── get_versions.py              # Version collection
└── data/
    ├── Deeplex/
```

## Input Data

### Deeplex Files

Place Excel files in `data/Deeplex/` directory:

```bash
data/Deeplex/
├── deeplex_batch_001.xlsx
└── deeplex_batch_002.xlsx
```

## Usage

### Basic Run

```bash
nextflow run main.nf
```

### Resume Failed Runs

```bash
nextflow run main.nf -resume
```

## Workflow Steps

### Deeplex Processing

1. **CONVERT_DEEPLEX**: Extract data from Excel files
2. **MERGE_CLINICAL_DEEPLEX**: Add DiagnosticReport

## Output Structure

```
results/
├── fhir_deeplex/                      # Deeplex-derived FHIR
│   └── deeplex_batch_001.json
├── fhir_deeplex_merged/               # Deeplex FHIR + DiagnosticReport
│   └── deeplex_batch_001.merged.fhir.json
└── runningstat/                       # Nextflow execution reports
    ├── execution.html
    ├── timeline.html
    └── dag.html
```
## [v1.4.0] - 2026-04-23

### Changed
- Removed VCF processing, lineage analysis, and sample report generation.
- Fixed UPLOAD_FHIR process to FHIR transaction bundles.
- Removed VCF-related parameters (vcf_dir, reference, repetitive_regions, lineage_barcode, clinical_metadata).
- Add custom LOINC code for specific Deeplex codon change (replacing gHGVS)

## Support
[GitHub Issues](https://github.com/oucru-id/tb-to-fhir-deeplex/issues)
