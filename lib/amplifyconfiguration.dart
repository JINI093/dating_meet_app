const amplifyconfig = '''{
    "UserAgent": "aws-amplify-cli/2.0",
    "Version": "1.0",
    "api": {
        "plugins": {
            "awsAPIPlugin": {
                "meet": {
                    "endpointType": "GraphQL",
                    "endpoint": "https://yqcwlxhcqrchlovxpvcuumpeq4.appsync-api.ap-northeast-2.amazonaws.com/graphql",
                    "region": "ap-northeast-2",
                    "authorizationType": "API_KEY",
                    "apiKey": "da2-42w2ezdixbcurfkvqdmgfatjja"
                }
            }
        }
    },
    "auth": {
        "plugins": {
            "awsCognitoAuthPlugin": {
                "UserAgent": "aws-amplify-cli/0.1.0",
                "Version": "0.1.0",
                "IdentityManager": {
                    "Default": {}
                },
                "AppSync": {
                    "Default": {
                        "ApiUrl": "https://yqcwlxhcqrchlovxpvcuumpeq4.appsync-api.ap-northeast-2.amazonaws.com/graphql",
                        "Region": "ap-northeast-2",
                        "AuthMode": "API_KEY",
                        "ApiKey": "da2-42w2ezdixbcurfkvqdmgfatjja",
                        "ClientDatabasePrefix": "meet_API_KEY"
                    }
                },
                "CredentialsProvider": {
                    "CognitoIdentity": {
                        "Default": {
                            "PoolId": "ap-northeast-2:b0244a25-b53b-4870-b740-3baed7eac93a",
                            "Region": "ap-northeast-2"
                        }
                    }
                },
                "CognitoUserPool": {
                    "Default": {
                        "PoolId": "ap-northeast-2_lKdTmyEaP",
                        "AppClientId": "cqu5l148pkrtoh0e28bh385ns",
                        "Region": "ap-northeast-2"
                    }
                },
                "Auth": {
                    "Default": {
                        "authenticationFlowType": "USER_SRP_AUTH",
                        "socialProviders": [],
                        "usernameAttributes": [],
                        "signupAttributes": [
                            "EMAIL"
                        ],
                        "passwordProtectionSettings": {
                            "passwordPolicyMinLength": 8,
                            "passwordPolicyCharacters": []
                        },
                        "mfaConfiguration": "OFF",
                        "mfaTypes": [
                            "SMS"
                        ],
                        "verificationMechanisms": [
                            "EMAIL"
                        ]
                    }
                },
                "S3TransferUtility": {
                    "Default": {
                        "Bucket": "meet62ba6c48f504412da023a6b393c9529ec1ba5-dev",
                        "Region": "ap-northeast-2"
                    }
                }
            }
        }
    },
    "storage": {
        "plugins": {
            "awsS3StoragePlugin": {
                "bucket": "meet62ba6c48f504412da023a6b393c9529ec1ba5-dev",
                "region": "ap-northeast-2",
                "defaultAccessLevel": "guest"
            }
        }
    }
}''';
