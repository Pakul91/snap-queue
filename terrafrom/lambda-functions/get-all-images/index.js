import { SNSClient, PublishCommand } from "@aws-sdk/client-sns";

export const handler = async (event) => {
  const snsClient = new SNSClient({});

  const message = {
    subject: "Test SNS Message",
    message: "This is a test message from Lambda",
  };

  const snsParams = {
    Message: JSON.stringify(message),
    TopicArn: process.env.SNS_TOPIC_ARN,
  };

  try {
    const snsResponse = await snsClient.send(new PublishCommand(snsParams));
    console.log("SNS Response:", snsResponse);
  } catch (error) {
    console.error("Error publishing to SNS:", error);
    throw error;
  }

  const response = {
    statusCode: 200,
    body: JSON.stringify({
      message: "Hello from Lambda!",
      input: event,
    }),
  };

  return response;
};
