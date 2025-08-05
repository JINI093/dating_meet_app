const amplifyconfig = '''{
    "UserAgent": "aws-amplify-cli/2.0",
    "Version": "1.0",
    "auth": {
        "plugins": {
            "awsCognitoAuthPlugin": {
                "UserAgent": "aws-amplify/cli",
                "Version": "1.0",
                "IdentityManager": {
                    "Default": {}
                },
                "CognitoUserPool": {
                    "Default": {
                        "PoolId": "ap-northeast-2_lKdTmyEaP",
                        "AppClientId": "cqu5l148pkrtoh0e28bh385ns",
                        "Region": "ap-northeast-2",
                        "UsernameAliases": ["email"],
                        "SignupAttributes": ["email"]
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
                "Auth": {
                    "Default": {
                        "authenticationFlowType": "USER_SRP_AUTH",
                        "socialProviders": [],
                        "usernameAttributes": ["email"],
                        "signupAttributes": ["email"],
                        "passwordProtectionSettings": {
                            "passwordPolicyMinLength": 8,
                            "passwordPolicyCharacters": []
                        },
                        "mfaConfiguration": "OFF",
                        "mfaTypes": ["SMS"],
                        "verificationMechanisms": ["EMAIL"]
                    }
                }
            }
        }
    },
    "api": {
        "plugins": {
            "awsAPIPlugin": {
                "meet": {
                    "endpointType": "GraphQL",
                    "endpoint": "https://yqcwlxhcqrchlovxpvcuumpeq4.appsync-api.ap-northeast-2.amazonaws.com/graphql",
                    "region": "ap-northeast-2",
                    "authorizationType": "API_KEY",
                    "apiKey": "da2-42w2ezdixbcurfkvqdmgfatjja"
                },
                "DatingMeetAPI": {
                    "endpointType": "REST",
                    "endpoint": "https://api.meet-project.com",
                    "region": "ap-northeast-2",
                    "authorizationType": "AMAZON_COGNITO_USER_POOLS"
                }
            }
        }
    },
    "storage": {
        "plugins": {
            "awsS3StoragePlugin": {
                "bucket": "meet-project",
                "region": "ap-northeast-2",
                "defaultAccessLevel": "protected"
            }
        }
    }
}''';
