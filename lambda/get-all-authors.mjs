import { DynamoDBClient, ScanCommand } from "@aws-sdk/client-dynamodb";

const client = new DynamoDBClient({ region: "eu-central-1" });

export const handler = async () => {
  try {
    const data = await client.send(new ScanCommand({ TableName: "roman-dev-authors" }));
    const authors = data.Items.map(item => ({
      id: item.id.S,
      firstName: item.firstName.S,
      lastName: item.lastName.S,
    }));
    return {
      statusCode: 200,
      headers: {
        "Content-Type":                "application/json",
        "Access-Control-Allow-Origin": "*" 
      },
      body: JSON.stringify(authors),
    };
  } catch (err) {
    console.error(err);
    return {
      statusCode: 500,
      headers: {
        "Content-Type":                "application/json",
        "Access-Control-Allow-Origin": "*"
      },
      body: JSON.stringify({ error: err.message }),
    };
  }
};
