// netlify/functions/api-proxy.js

const ORACLE_API_BASE = 'https://g9f388f29ddf339-ve8wjezt6vnl93qx.adb.sa-vinhedo-1.oraclecloudapps.com/ords/rodrigo/';

exports.handler = async (event) => {
    // Only allow POST requests
    if (event.httpMethod !== 'POST') {
        return {
            statusCode: 405,
            body: JSON.stringify({ error: 'Method not allowed' })
        };
    }

    try {
        // Parse request body
        const body = JSON.parse(event.body);
        
        // Extract the endpoint from the request
        const endpoint = body.endpoint;
        
        if (!endpoint) {
            return {
                statusCode: 400,
                body: JSON.stringify({ error: 'Endpoint parameter required' })
            };
        }

        // Remove endpoint from body to avoid passing it to Oracle
        delete body.endpoint;

        // Call Oracle API
        const response = await fetch(`${ORACLE_API_BASE}${endpoint}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(body)
        });

        // Get response data
        const data = await response.json();

        // Return response
        return {
            statusCode: response.status,
            body: JSON.stringify(data)
        };

    } catch (error) {
        console.error('Proxy error:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({ 
                error: 'Server error', 
                message: error.message 
            })
        };
    }
};