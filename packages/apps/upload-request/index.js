import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { v4 as uuidv4 } from "uuid";

// Initialize S3 client
const s3Client = new S3Client({ region: process.env.AWS_REGION });
const BUCKET_NAME = process.env.RAW_IMAGE_BUCKET_NAME;

export const handler = async (event, context) => {
  console.log("Received event:", JSON.stringify(event, null, 2));

  try {
    const requestBody = event.body ? JSON.parse(event.body) : {};

    const fileExtension = requestBody.fileExtension;

    // Generate a unique filename with UUID to prevent overwriting
    const fileName = `${uuidv4()}${fileExtension}`;

    // Create a command for the PUT operation
    const command = new PutObjectCommand({
      Bucket: BUCKET_NAME,
      Key: fileName,
      ContentType: requestBody.contentType || "image/jpeg",
    });

    const signedUrl = await getSignedUrl(s3Client, command, { expiresIn: 900 });

    return {
      statusCode: 200,
      body: JSON.stringify({
        message: "Pre-signed URL generated successfully",
        uploadUrl: signedUrl,
        fileName: fileName,
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
