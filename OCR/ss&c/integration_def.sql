-- SS&C Captricity / Blue Prism Document Automation — integration definitions
-- Auth: Captricity-API-Token (local AES). Scripts use `request` (IH wrap alias for body).
-- ApiConnector supports multipart/form-data via fileBase64 + fileName → uploaded_file part.
-- API ref: https://documentation.blueprism.com/document-automation/en-us/system-settings/api-integration.htm

-- 1) Create batch
INSERT INTO integration_definitions (
    integration_id, definition_json, auth, created_at, updated_at, integration_name, payload_schema, version
)
SELECT
    gen_random_uuid(),
    $JSON${
      "connector": {
        "uri": "https://shreddr.captricity.com/api/v1/batch/",
        "type": "API",
        "parameters": { "method": "POST", "Content-Type": "application/json" }
      },
      "transformation": {
        "requestScript": "var b = request || {}; var wf = b.workflowId || b.workflow_id; function uuidv4() { return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) { var r = Math.random() * 16 | 0; var v = c === 'x' ? r : (r & 0x3 | 0x8); return v.toString(16); }); } var out = { name: b.batchName || b.name || uuidv4() }; if (wf) { out.workflow_id = parseInt(wf, 10); } response = out;",
        "responseScript": "var b = request || {}; response = { batchId: String(b.id || b.batch_id || ''), raw: b };"
      }
    }$JSON$::jsonb,
    $JSON${ "authType": "API_KEY", "keyname": "Captricity-API-Token", "value": "local:4tNAemjnKSAc/WNxGO0o4mn24RxhJPtvW3SRf/fcs6wlRPfpStyztg+9tWgv8Yhv" }$JSON$::jsonb,
    NOW(), NOW(),
    'ssc-ocr-create-batch',
    $JSON${ "type": "object", "properties": { "batchName": { "type": "string" }, "name": { "type": "string" }, "workflowId": { "type": "string" } } }$JSON$::jsonb,
    1
WHERE NOT EXISTS (SELECT 1 FROM integration_definitions WHERE integration_name = 'ssc-ocr-create-batch');

-- 2) Add batch file (multipart: fileBase64 OR s3Key)
INSERT INTO integration_definitions (
    integration_id, definition_json, auth, created_at, updated_at, integration_name, payload_schema, version
)
SELECT
    gen_random_uuid(),
    $JSON${
      "connector": {
        "uri": "https://shreddr.captricity.com/api/v1/batch/{batchId}/batch-file/",
        "type": "API",
        "parameters": { "method": "POST", "Content-Type": "multipart/form-data" }
      },
      "transformation": {
        "requestScript": "var b = request || {}; var meta = b.metadata || { batch_file_metadata: [{ metadata: { communication_ref: String(b.communicationId || b.batchId || '') } }] }; response = { fileName: b.fileName || 'document.pdf', fileBase64: b.fileBase64 || b.file_base64, s3Key: b.s3Key || b.s3_key, fileField: 'uploaded_file', contentType: b.contentType || 'application/pdf', batchId: b.batchId, metadata: meta };",
        "responseScript": "var b = request || {}; response = { batchFileId: String(b.id || ''), raw: b };"
      }
    }$JSON$::jsonb,
    $JSON${ "authType": "API_KEY", "keyname": "Captricity-API-Token", "value": "local:4tNAemjnKSAc/WNxGO0o4mn24RxhJPtvW3SRf/fcs6wlRPfpStyztg+9tWgv8Yhv" }$JSON$::jsonb,
    NOW(), NOW(),
    'ssc-ocr-add-batch-file',
    $JSON${ "type": "object", "required": ["batchId"], "properties": { "batchId": { "type": "string" }, "fileName": { "type": "string" }, "fileBase64": { "type": "string" }, "s3Key": { "type": "string" } } }$JSON$::jsonb,
    1
WHERE NOT EXISTS (SELECT 1 FROM integration_definitions WHERE integration_name = 'ssc-ocr-add-batch-file');

-- 3) Submit batch
INSERT INTO integration_definitions (
    integration_id, definition_json, auth, created_at, updated_at, integration_name, payload_schema, version
)
SELECT
    gen_random_uuid(),
    $JSON${
      "connector": {
        "uri": "https://shreddr.captricity.com/api/v1/batch/{batchId}/submit",
        "type": "API",
        "parameters": { "method": "POST", "Content-Type": "application/json" }
      },
      "transformation": {
        "requestScript": "response = {};",
        "responseScript": "response = { submitted: true, raw: request || {} };"
      }
    }$JSON$::jsonb,
    $JSON${ "authType": "API_KEY", "keyname": "Captricity-API-Token", "value": "local:4tNAemjnKSAc/WNxGO0o4mn24RxhJPtvW3SRf/fcs6wlRPfpStyztg+9tWgv8Yhv" }$JSON$::jsonb,
    NOW(), NOW(),
    'ssc-ocr-submit-batch',
    $JSON${ "type": "object", "required": ["batchId"], "properties": { "batchId": { "type": "string" } } }$JSON$::jsonb,
    1
WHERE NOT EXISTS (SELECT 1 FROM integration_definitions WHERE integration_name = 'ssc-ocr-submit-batch');

-- 4) Get case data
INSERT INTO integration_definitions (
    integration_id, definition_json, auth, created_at, updated_at, integration_name, payload_schema, version
)
SELECT
    gen_random_uuid(),
    $JSON${
      "connector": {
        "uri": "https://shreddr.captricity.com/api/v1/cases/{caseId}/data",
        "type": "API",
        "parameters": { "method": "GET" }
      },
      "transformation": {
        "requestScript": "response = {};",
        "responseScript": "response = request || {};"
      }
    }$JSON$::jsonb,
    $JSON${ "authType": "API_KEY", "keyname": "Captricity-API-Token", "value": "local:4tNAemjnKSAc/WNxGO0o4mn24RxhJPtvW3SRf/fcs6wlRPfpStyztg+9tWgv8Yhv" }$JSON$::jsonb,
    NOW(), NOW(),
    'ssc-ocr-get-case-data',
    $JSON${ "type": "object", "required": ["caseId"], "properties": { "caseId": { "type": "string" } } }$JSON$::jsonb,
    1
WHERE NOT EXISTS (SELECT 1 FROM integration_definitions WHERE integration_name = 'ssc-ocr-get-case-data');

-- 5) Mark exported
INSERT INTO integration_definitions (
    integration_id, definition_json, auth, created_at, updated_at, integration_name, payload_schema, version
)
SELECT
    gen_random_uuid(),
    $JSON${
      "connector": {
        "uri": "https://shreddr.captricity.com/api/v1/cases/update_statuses_to_exported",
        "type": "API",
        "parameters": { "method": "POST", "Content-Type": "application/json" }
      },
      "transformation": {
        "requestScript": "var b = request || {}; var ids = b.caseIds || b.case_ids || []; response = { case_ids: ids };",
        "responseScript": "response = request || {};"
      }
    }$JSON$::jsonb,
    $JSON${ "authType": "API_KEY", "keyname": "Captricity-API-Token", "value": "local:4tNAemjnKSAc/WNxGO0o4mn24RxhJPtvW3SRf/fcs6wlRPfpStyztg+9tWgv8Yhv" }$JSON$::jsonb,
    NOW(), NOW(),
    'ssc-ocr-mark-exported',
    $JSON${ "type": "object", "properties": { "caseIds": { "type": "array", "items": { "type": "integer" } } } }$JSON$::jsonb,
    1
WHERE NOT EXISTS (SELECT 1 FROM integration_definitions WHERE integration_name = 'ssc-ocr-mark-exported');

-- 6) Process batch (case-automation)
INSERT INTO integration_definitions (
    integration_id, definition_json, auth, created_at, updated_at, integration_name, payload_schema, version
)
SELECT
    gen_random_uuid(),
    $JSON${
      "connector": {
        "uri": "http://case-automation:8091/api/case-automation/v1/ocr-webhook/process-batch",
        "type": "WEBHOOK",
        "parameters": { "method": "POST", "Content-Type": "application/json" }
      },
      "defaultRequestMode": "sync",
      "transformation": {
        "requestScript": "response = request || {};"
      }
    }$JSON$::jsonb,
    $JSON${ "authType": "NO_AUTH" }$JSON$::jsonb,
    NOW(), NOW(),
    'ssc-ocr-process-batch',
    $JSON${ "type": "object", "properties": { "batchUuid": { "type": "string" }, "caseId": { "type": "string" }, "fetchResponse": { "type": "object" } } }$JSON$::jsonb,
    1
WHERE NOT EXISTS (SELECT 1 FROM integration_definitions WHERE integration_name = 'ssc-ocr-process-batch');

-- Idempotent refresh of Captricity defs (auth + definition_json)
UPDATE integration_definitions SET
  auth = $JSON${ "authType": "API_KEY", "keyname": "Captricity-API-Token", "value": "local:4tNAemjnKSAc/WNxGO0o4mn24RxhJPtvW3SRf/fcs6wlRPfpStyztg+9tWgv8Yhv" }$JSON$::jsonb,
  definition_json = CASE integration_name
    WHEN 'ssc-ocr-create-batch' THEN $JSON${
      "connector": { "uri": "https://shreddr.captricity.com/api/v1/batch/", "type": "API", "parameters": { "method": "POST", "Content-Type": "application/json" } },
      "transformation": {
        "requestScript": "var b = request || {}; var wf = b.workflowId || b.workflow_id; function uuidv4() { return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) { var r = Math.random() * 16 | 0; var v = c === 'x' ? r : (r & 0x3 | 0x8); return v.toString(16); }); } var out = { name: b.batchName || b.name || uuidv4() }; if (wf) { out.workflow_id = parseInt(wf, 10); } response = out;",
        "responseScript": "var b = request || {}; response = { batchId: String(b.id || b.batch_id || ''), raw: b };"
      }
    }$JSON$::jsonb
    WHEN 'ssc-ocr-add-batch-file' THEN $JSON${
      "connector": { "uri": "https://shreddr.captricity.com/api/v1/batch/{batchId}/batch-file/", "type": "API", "parameters": { "method": "POST", "Content-Type": "multipart/form-data" } },
      "transformation": {
        "requestScript": "var b = request || {}; var meta = { batch_file_metadata: [{ metadata: { communication_ref: String(b.communicationId || b.batchId || '') } }] }; response = { fileName: b.fileName || 'document.pdf', fileBase64: b.fileBase64 || b.file_base64, fileField: 'uploaded_file', contentType: b.contentType || 'application/pdf', batchId: b.batchId, metadata: meta };",
        "responseScript": "var b = request || {}; response = { batchFileId: String(b.id || ''), raw: b };"
      }
    }$JSON$::jsonb
    WHEN 'ssc-ocr-submit-batch' THEN $JSON${
      "connector": { "uri": "https://shreddr.captricity.com/api/v1/batch/{batchId}/submit", "type": "API", "parameters": { "method": "POST", "Content-Type": "application/json" } },
      "transformation": {
        "requestScript": "response = {};",
        "responseScript": "response = { submitted: true, raw: request || {} };"
      }
    }$JSON$::jsonb
    WHEN 'ssc-ocr-get-case-data' THEN $JSON${
      "connector": { "uri": "https://shreddr.captricity.com/api/v1/cases/{caseId}/data", "type": "API", "parameters": { "method": "GET" } },
      "transformation": {
        "requestScript": "response = {};",
        "responseScript": "response = request || {};"
      }
    }$JSON$::jsonb
    WHEN 'ssc-ocr-mark-exported' THEN $JSON${
      "connector": { "uri": "https://shreddr.captricity.com/api/v1/cases/update_statuses_to_exported", "type": "API", "parameters": { "method": "POST", "Content-Type": "application/json" } },
      "transformation": {
        "requestScript": "var b = request || {}; var ids = b.caseIds || b.case_ids || []; response = { case_ids: ids };",
        "responseScript": "response = request || {};"
      }
    }$JSON$::jsonb
    ELSE definition_json
  END,
  updated_at = NOW()
WHERE integration_name IN (
  'ssc-ocr-create-batch',
  'ssc-ocr-add-batch-file',
  'ssc-ocr-submit-batch',
  'ssc-ocr-get-case-data',
  'ssc-ocr-mark-exported'
);

UPDATE integration_definitions SET
  definition_json = jsonb_set(definition_json, '{transformation,requestScript}', to_jsonb('response = request || {};'::text)),
  updated_at = NOW()
WHERE integration_name = 'ssc-ocr-process-batch';


UPDATE integration_definitions SET
  definition_json = CASE integration_name
    WHEN 'ssc-ocr-create-batch' THEN $JSON${
      "connector": { "uri": "https://shreddr.captricity.com/api/v1/batch/", "type": "API", "parameters": { "method": "POST", "Content-Type": "application/json" } },
      "transformation": {
        "requestScript": "var b = request || {}; var wf = b.workflowId || b.workflow_id; function uuidv4() { return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) { var r = Math.random() * 16 | 0; var v = c === 'x' ? r : (r & 0x3 | 0x8); return v.toString(16); }); } var out = { name: b.batchName || b.name || uuidv4() }; if (wf) { out.workflow_id = parseInt(wf, 10); } response = out;",
        "responseScript": "var b = request || {}; response = { batchId: String(b.id || b.batch_id || ''), raw: b };"
      }
    }$JSON$::jsonb
    WHEN 'ssc-ocr-add-batch-file' THEN $JSON${
      "connector": { "uri": "https://shreddr.captricity.com/api/v1/batch/{batchId}/batch-file/", "type": "API", "parameters": { "method": "POST", "Content-Type": "multipart/form-data" } },
      "transformation": {
        "requestScript": "var b = request || {}; var meta = b.metadata || { batch_file_metadata: [{ metadata: { communication_ref: String(b.communicationId || b.batchId || '') } }] }; response = { fileName: b.fileName || 'document.pdf', fileBase64: b.fileBase64 || b.file_base64, s3Key: b.s3Key || b.s3_key, fileField: 'uploaded_file', contentType: b.contentType || 'application/pdf', batchId: b.batchId, metadata: meta };",
        "responseScript": "var b = request || {}; response = { batchFileId: String(b.id || ''), raw: b };"
      }
    }$JSON$::jsonb
    WHEN 'ssc-ocr-submit-batch' THEN $JSON${
      "connector": { "uri": "https://shreddr.captricity.com/api/v1/batch/{batchId}/submit", "type": "API", "parameters": { "method": "POST", "Content-Type": "application/json" } },
      "transformation": {
        "requestScript": "response = {};",
        "responseScript": "response = { submitted: true, raw: request || {} };"
      }
    }$JSON$::jsonb
    ELSE definition_json
  END,
  payload_schema = CASE integration_name
    WHEN 'ssc-ocr-add-batch-file' THEN $JSON${ "type": "object", "required": ["batchId"], "properties": { "batchId": { "type": "string" }, "fileName": { "type": "string" }, "fileBase64": { "type": "string" }, "s3Key": { "type": "string" } } }$JSON$::jsonb
    ELSE payload_schema
  END,
  updated_at = NOW()
WHERE integration_name IN (
  'ssc-ocr-create-batch',
  'ssc-ocr-add-batch-file',
  'ssc-ocr-submit-batch'
);
