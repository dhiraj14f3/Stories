

var response = {
  status: 'SUCCESS',
  valid: true,
  data: {}
};

var caseParam;
var specialtyPharmacyId;

try {
  console.log('Parsing input parameter...');
  var fullObj = JSON.parse(parameter);
  console.log('Parsed object:', JSON.stringify(fullObj));
  
  caseParam = fullObj;
  console.log('Assigned caseParam:', JSON.stringify(caseParam));

  // Corrected access path
  specialtyPharmacyId = caseParam?.data?.caseObj?.patient_pharmacy_id;
  console.log('Extracted specialtyPharmacyId:', specialtyPharmacyId);
} catch (e) {
  console.log('Error parsing JSON:', e);
  response.data.sp_triage_status = false;
  response.data.pharmacy_missing_message = 'Pharmacy id is required.';
  return response;
}

var isValid = specialtyPharmacyId !== null && specialtyPharmacyId !== undefined;
console.log('Is specialtyPharmacyId valid?', isValid);

// Final output setup
response.data.sp_triage_status = isValid;
if (!isValid) {
  response.data.pharmacy_missing_message = 'Pharmacy id is required.';
}

console.log('Final response:', JSON.stringify(response));
return response;

    