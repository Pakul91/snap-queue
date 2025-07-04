import { S3Client, HeadObjectCommand } from "@aws-sdk/client-s3";
import { DynamoDBClient, PutItemCommand } from "@aws-sdk/client-dynamodb";
import { marshall } from "@aws-sdk/util-dynamodb";

// Initialize clients
const s3Client = new S3Client();
const dynamoClient = new DynamoDBClient();

// Get environment variables
const IMAGE_TABLE_NAME = process.env.IMAGE_TABLE_NAME;

export const handler = async (event, context) => {
  try {
    // Log the incoming event
    console.log("Processing SQS event:", JSON.stringify(event, null, 2));

    // Process each record in the SQS batch
    for (const record of event.Records) {
      // Parse the S3 event from SQS message body
      const s3Event = JSON.parse(record.body);
      const bucket = s3Event.Records[0].s3.bucket.name;
      const key = s3Event.Records[0].s3.object.key;

      // Extract the UUID from the key (assuming key is the UUID filename)
      // const imageId = key.split(".")[0]; // Remove file extension to get clean UUID

      // Get image metadata from S3
      const headObjectCommand = new HeadObjectCommand({
        Bucket: bucket,
        Key: key,
      });

      const headResponse = await s3Client.send(headObjectCommand);
      const metadata = headResponse.Metadata || {};

      const imageId = Date.now().toString(); // Temporary solution, replace with actual logic to extract UUID
      const userId = metadata.userId || "pakulniewicz.t@gmail.com"; // Example user ID, replace with actual logic
      const sessionId = "session-12345"; // Example session ID, replace with actual logic
      const originalFileName = metadata.originalFileName || key; // Use the key as the original file name if not provided

      // Log the metadata
      console.log("Image metadata from S3:", JSON.stringify(metadata, null, 2));

      // Create a plain JavaScript object to represent the DynamoDB item
      const item = {
        ImageId: imageId,
        UserId: userId,
        SessionId: sessionId,
        OriginalFileName: originalFileName,
        Bucket: bucket,
        Key: key,
        ContentType: headResponse.ContentType || "image/jpeg",
        createdAt: new Date().toISOString(),
        Size: headResponse.ContentLength || 0,
      };

      console.log("Item before marshalling:", JSON.stringify(item, null, 2));

      // Use marshall to convert the JavaScript object to DynamoDB format
      const marshalledItem = marshall(item, {
        convertEmptyValues: true,
        removeUndefinedValues: true,
      });

      console.log(
        "Storing marshalled item in DynamoDB:",
        JSON.stringify(marshalledItem, null, 2)
      );

      // Store the image metadata in DynamoDB
      const putCommand = new PutItemCommand({
        TableName: IMAGE_TABLE_NAME,
        Item: marshalledItem,
      });

      await dynamoClient.send(putCommand);
      console.log(`Image metadata stored in DynamoDB: ${imageId}`);
    }

    return {
      statusCode: 200,
      body: JSON.stringify({ message: "Image metadata stored successfully" }),
    };
  } catch (error) {
    console.error("Error processing image:", error);
    throw error; // Let Lambda handle the error
  }
};
