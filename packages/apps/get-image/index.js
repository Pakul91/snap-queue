export const handler = async (event, context) => {
  console.log("Received event:", JSON.stringify(event, null, 2));
  console.log("Context:", JSON.stringify(context, null, 2));

  const response = {
    statusCode: 200,
    body: JSON.stringify({
      message: "Hello from get Image!",
      input: event,
    }),
  };

  return response;
};
