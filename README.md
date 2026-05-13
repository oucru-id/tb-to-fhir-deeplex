A Nextflow pipeline for converting Mycobacterium tuberculosis Deeplex Myc-TB Excel genomic data to HL7 FHIR R4 Genomics format. [Full documentation](https://deeplex-tb-to-fhir.readthedocs.io/)

## Installation

From the repo
```bash
git clone https://github.com/oucru-id/tb-to-fhir-deeplex.git
cd tb-to-fhir-deeplex
```

## Directory Structure

```
tb-to-fhir-deeplex
├── main.nf                          # Main workflow
├── nextflow.config                  # Configuration
├── workflows/
│   ├── deeplex.nf                   # Deeplex processing
│   ├── upload_fhir.nf               # FHIR uploader
│   └── utils.nf                     # Utility functions
├── scripts/
│   ├── xlsx_json_converter.py       # Deeplex to FHIR converter
│   ├── merge_clinical_deeplex.py    # DiagnosticReport data merge
│   └── get_versions.py              # Version collection
│   └── upload_fhir.py               # FHIR uploader
│   └── get_access_token.py          # Standalone script to get the access token to FHIR server
│   └── get_patient_by_nik.py        # Standalone script to get patient UUID
└── data/
│   ├── Deeplex/
│   └── access_token.json              # Access token generated
│   └── input_sso.json                 # SSO info to generate token
│   └── sampletopatientid_mapping.csv  # Mapping patient UUID with Deeplex's sample ID 
```

## Input Data

### Deeplex Files

Place Excel files in `data/Deeplex/` directory

## Usage

### Get Access Token to FHIR Server
> Fill the input_sso.json first
```bash
python3 scripts/get_access_token.py
```

### Basic Run

```bash
nextflow run main.nf
```

### Run and Upload to FHIR Server
> Get the access token first before running the pipeline
```bash
nextflow run main.nf \
  --fhir_server_url "https://<BASE_URL>/fhir"
```

## Drug Resistance Classification

The `DiagnosticReport` conclusion is derived using the following order:

| Classification | Criteria |
|---|---|
| XDR-TB | MDR/RR + Fluoroquinolone resistance + Group A drug resistance |
| Pre-XDR-TB | MDR/RR + Fluoroquinolone resistance |
| MDR-TB | Resistance to both Isoniazid and Rifampicin |
| RR-TB | Rifampicin resistance only |
| HR-TB | Isoniazid resistance only |
| Mono-resistant | Single drug resistance (Streptomycin, Ethionamide, Pyrazinamide, Ethambutol, or Ciprofloxacin) |
| Drug-resistant | Any other resistance combination |
| Sensitive | No resistance detected |

## Output Structure

```
results/
├── fhir_deeplex/                      # Deeplex-derived FHIR
│   └── deeplex_batch_001.json
├── fhir_deeplex_merged/               # Deeplex FHIR + DiagnosticReport
│   └── deeplex_batch_001.merged.fhir.json
├── fhir_upload/                       # Uploaded FHIR responses
│   └── deeplex_batch_001.merged.fhir.upload.json
└── runningstat/                       # Nextflow execution reports
    ├── execution.html
    ├── timeline.html
    └── dag.html
```

## Support
[GitHub Issues](https://github.com/oucru-id/tb-to-fhir-deeplex/issues)
