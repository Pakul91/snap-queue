import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { v4 as uuidv4 } from "uuid";

// Initialize S3 client
const s3Client = new S3Client({ region: process.env.AWS_REGION });
const BUCKET_NAME = process.env.RAW_IMAGE_BUCKET_NAME;

export const handler = async (event, context) => {
  console.log("Received event:", JSON.stringify(event, null, 2));

  try {
    // Generate a unique filename with UUID to prevent overwriting
    const fileName = uuidv4();

    const requestData = event.queryStringParameters || {};
    const userId = requestData.userId || "defaultUser"; // Default user ID if
    const originalFileName = requestData.originalFileName || "image.jpg"; // Default file name if not provided

    // Create a command for the PUT operation
    const command = new PutObjectCommand({
      Bucket: BUCKET_NAME,
      Key: fileName,
      Metadata: {
        userId: userId,
        originalFileName: originalFileName,
      },
    });

    const signedUrl = await getSignedUrl(s3Client, command, { expiresIn: 30 });

    return {
      statusCode: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Credentials": true,
      },
      body: JSON.stringify({
        uploadUrl: signedUrl,
      }),
    };
  } catch (error) {
    console.error("Error generating pre-signed URL:", error);

    // Return error response
    return {
      statusCode: 500,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Credentials": true,
      },
      body: JSON.stringify({
        message: "Error generating pre-signed URL",
        error: error.message,
      }),
    };
  }
};
