/*
AWS Lambda function to determine user signup eligibility based on allowed email domains

This Lambda function takes an event object containing user attributes and checks
if the user's email domain is present in the allowedDomains array. If the domain is
allowed, it calls the callback with no error (null) and the event object, indicating
that the user is eligible for signup. If the domain is not allowed, it creates an error
object with an appropriate user-friendly message and calls the callback with the error
and the event object, indicating that the user is not eligible for signup due to the domain.
*/

exports.handler = async (event, context, callback) => {
    const userEmailDomain = event.request.userAttributes.email.split("@")[1];
    const allowedDomains = ['gmail.com', 'yahoo.com'];
  
    if (allowedDomains.includes(userEmailDomain)) {
      // The user's email domain is allowed, so they are eligible for signup
      callback(null, event);
    } else {
      // The user's email domain is not allowed, so they are not eligible for signup
      const error = new Error(`Sorry, we only accept signups with email addresses from ${allowedDomains.join(', ')}.`);
      callback(error, event);
    }
  };
  