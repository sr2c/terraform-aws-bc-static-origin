'use strict';

const reportURI = "/sentry/api/2/security/?sentry_key=a5423dd760fe46e989430f42a880f3e1"
const csp = `
default-src https://*.cloudfront.net 'self';
script-src https://*.cloudfront.net 'report-sample' 'self';
style-src 'report-sample' 'self';
object-src 'none';
base-uri 'self';
connect-src https://*.cloudfront.net 'self';
font-src 'self';
frame-src 'self';
img-src https://*.cloudfront.net 'self' data:;
manifest-src 'self';
media-src https://*.cloudfront.net 'self';
report-uri ${reportURI};
worker-src 'none';
`

const compiledCSP = csp.replace(/\n/g, ' ').trim();

exports.handler = (event, context, callback) => {
  // Get contents of request and response
  const request = event.Records[0].cf.request;
  const response = event.Records[0].cf.response;
  const headers = response.headers;

  if (request.uri.startsWith("/sentry")) {
    // no-op
  } else {
    // Set new headers
    // The name of the header must be in lowercase and must match the value of key except for case.
    headers['strict-transport-security'] = [{ key: 'Strict-Transport-Security', value: 'max-age=63072000; includeSubdomains; preload' }];
    headers['content-security-policy-report-only'] = [{ key: 'Content-Security-Policy-Report-Only', value: compiledCSP }];
    headers['x-content-type-options'] = [{ key: 'X-Content-Type-Options', value: 'nosniff' }];
    headers['x-frame-options'] = [{ key: 'X-Frame-Options', value: 'DENY' }];
    headers['x-xss-protection'] = [{ key: 'X-XSS-Protection', value: '1; mode=block' }];
    headers['referrer-policy'] = [{ key: 'Referrer-Policy', value: 'same-origin' }];
    headers['cross-origin-resource-policy'] = [{ key: 'Cross-Origin-Resource-Policy', value: 'cross-origin' }]
    headers['cross-origin-opener-policy-report-only'] = [{ key: 'Cross-Origin-Opener-Policy-Report-Only', value: 'same-origin; report-to="default"' }]
    headers['cross-origin-embedder-policy-report-only'] = [{ key: 'Cross-Origin-Embedder-Policy-Report-Only', value: 'require-corp; report-to="default"' }]
    headers['expect-ct'] = [{ key: 'Expect-CT', value: `max-age=604800, report-uri="${reportURI}"` }]

    // extra for weblite
    headers['permissions-policy'] = [{ key: 'Permissions-Policy', value: 'microphone=(self)' }]
  }
  // Return modified response
  callback(null, response);
};
