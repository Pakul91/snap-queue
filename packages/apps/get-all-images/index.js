export const handler = async (event, context) => {
  const response = {
    statusCode: 200,
    body: JSON.stringify({
      message: "Hello from get all images!",
      input: event,
    }),
  };

  return response;
};
