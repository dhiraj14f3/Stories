var caseParam;
try {
    var fullObj = JSON.parse(parameter);
    caseParam = fullObj?.data?.caseObj;
} catch (e) {
    response.status = 'SUCCESS';
    response.valid = false;
    response.messageMap['case.required'] = 'Invalid input format. Please provide valid JSON data.';
    response.messages.push('Invalid input format. Please provide valid JSON data.');
    return response;
}

const provider = caseParam?.c_provider;
const patient = caseParam?.patient;
const shipmentList = caseParam?.c_case_shipment_address_case || [];
const orderDetails = caseParam?.case_order_details;
const pharmacyId = caseParam?.patient_pharmacy_id;

const errorMessages = {
    provider: {
        base: 'Provider information is required.',
        first_name: 'Provider first name is required.',
        last_name: 'Provider last name is required.'
    },
    patient: {
        base: 'Patient information is required.',
        first_name: 'Patient first name is required.',
        last_name: 'Patient last name is required.',
        date_of_birth: 'Patient date of birth is required.',
        pharmacy_id: 'Patient pharmacy ID is required.'
    },

    shipment: {
        base: 'Shipment information is required.',
        address: {
            address_line_1: 'Shipment address line 1 is required.',
            city: 'Shipment city is required.',
            state: 'Shipment state is required.',
            zip_code: 'Shipment zip code is required.'
        },
        ship_to_entity: 'Ship to entity is required.'
    },
    orderDetails: {
        base: 'Order details are required.',
        fulfillment_type: 'Order fulfillment type is required.',
        fill_type: 'Order fill type is required.',
        distributor_name: 'Order distributor name is required.'
    }
};

const messages = [];
const messageMap = {};

/* ---------------- Provider ---------------- */
if (!provider) {
    messages.push(errorMessages.provider.base);
    messageMap['case.provider.first_name.required'] =
        errorMessages.provider.first_name;
    messageMap['case.provider.last_name.required'] =
        errorMessages.provider.last_name;
} else {
    if (!provider.first_name) {
        messages.push(errorMessages.provider.first_name);
        messageMap['case.provider.first_name.required'] =
            errorMessages.provider.first_name;
    }
    if (!provider.last_name) {
        messages.push(errorMessages.provider.last_name);
        messageMap['case.provider.last_name.required'] =
            errorMessages.provider.last_name;
    }
}

/* ---------------- Shipment ---------------- */
if (!shipmentList.length) {
    messages.push(errorMessages.shipment.base);
    messageMap['case.shipment.ship_to_entity.required'] =
        errorMessages.shipment.ship_to_entity;
    messageMap['case.shipment.address.address_line_1.required'] =
        errorMessages.shipment.address.address_line_1;
    messageMap['case.shipment.address.city.required'] =
        errorMessages.shipment.address.city;
    messageMap['case.shipment.address.state.required'] =
        errorMessages.shipment.address.state;
    messageMap['case.shipment.address.zip_code.required'] =
        errorMessages.shipment.address.zip_code;
} else {
    const s = shipmentList[0];
    if (!s.ship_to_entity) {
        messages.push(errorMessages.shipment.ship_to_entity);
        messageMap['case.shipment.ship_to_entity.required'] =
            errorMessages.shipment.ship_to_entity;
    }
    if (!s.address_line_1) {
        messages.push(errorMessages.shipment.address.address_line_1);
        messageMap['case.shipment.address.address_line_1.required'] =
            errorMessages.shipment.address.address_line_1;
    }
    if (!s.city) {
        messages.push(errorMessages.shipment.address.city);
        messageMap['case.shipment.address.city.required'] =
            errorMessages.shipment.address.city;
    }
    if (!s.state) {
        messages.push(errorMessages.shipment.address.state);
        messageMap['case.shipment.address.state.required'] =
            errorMessages.shipment.address.state;
    }
    if (!s.zipcode) {
        messages.push(errorMessages.shipment.address.zip_code);
        messageMap['case.shipment.address.zip_code.required'] =
            errorMessages.shipment.address.zip_code;
    }
}

/* ---------------- Patient ---------------- */
if (!patient) {
    messages.push(errorMessages.patient.base);
    messageMap['case.patient.required'] =
        errorMessages.patient.base;
} else {
    if (!patient.first_name) {
        messages.push(errorMessages.patient.first_name);
        messageMap['case.patient.first_name.required'] =
            errorMessages.patient.first_name;
    }
    if (!patient.last_name) {
        messages.push(errorMessages.patient.last_name);
        messageMap['case.patient.last_name.required'] =
            errorMessages.patient.last_name;
    }
    if (!patient.date_of_birth) {
        messages.push(errorMessages.patient.date_of_birth);
        messageMap['case.patient.date_of_birth.required'] =
            errorMessages.patient.date_of_birth;
    }
    if (!pharmacyId) {
        messages.push(errorMessages.patient.pharmacy_id);
        messageMap['case.patient.pharmacy_id.required'] =
            errorMessages.patient.pharmacy_id;
    }
}

/* ---------------- Order Details ---------------- */
if (!orderDetails) {
    messages.push(errorMessages.orderDetails.base);
    messageMap['case.order_details.fulfillment_type.required'] =
        errorMessages.orderDetails.fulfillment_type;
    messageMap['case.order_details.fill_type.required'] =
        errorMessages.orderDetails.fill_type;
    messageMap['case.order_details.distributor_name.required'] =
        errorMessages.orderDetails.distributor_name;
}


/* ---------------- Template Mapping ---------------- */
const templateLabelMapping = {
    'case.provider.first_name.required':
        'Provider First Name||MI-PERFN , Prescriber Full Name',
    'case.provider.last_name.required':
        'Provider Last Name||MI-PERFN , Prescriber Full Name',

    'case.patient.first_name.required':
        'Patient First Name||MI-PATFN , Patient Full Name',
    'case.patient.last_name.required':
        'Patient Last Name||MI-PATFN , Patient Full Name',
    'case.patient.date_of_birth.required':
        'Patient Date of Birth||MI-PATDOB , Patient DOB',
    'case.patient.pharmacy_id.required':
        'Patient Pharmacy ID||MI-PHARMID , Pharmacy ID',


    'case.shipment.ship_to_entity.required':
        'Shipment Ship To||MI-OTHERTEVA , Other',
    'case.shipment.address.address_line_1.required':
        'Shipment Address||MI-OTHERTEVA , Other',
    'case.shipment.address.city.required':
        'Shipment City||MI-OTHERTEVA , Other',
    'case.shipment.address.state.required':
        'Shipment State||MI-OTHERTEVA , Other',
    'case.shipment.address.zip_code.required':
        'Shipment Zip||MI-OTHERTEVA , Other',

    'case.order_details.fulfillment_type.required':
        'Order Fulfillment Type||MI-OTHERTEVA , Other',
    'case.order_details.fill_type.required':
        'Order Fill Type||MI-OTHERTEVA , Other',
    'case.order_details.distributor_name.required':
        'Order Distributor Name||MI-OTHERTEVA , Other',

};



const finalMessageMap = {};
for (const key in messageMap) {
    const label = templateLabelMapping[key] || 'Other';
    finalMessageMap[key + '::' + label] = messageMap[key];
}

response.status = messages.length > 0 ? 'FAILURE' : 'SUCCESS';
response.valid = messages.length === 0;
response.messages = messages;
response.messageMap = finalMessageMap;
response.data = {
    result: messages.length > 0 ? 'TRUE' : 'FALSE'
};

return response;





    