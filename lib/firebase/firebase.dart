import 'package:googleapis_auth/auth_io.dart';

class GetServerKey{
  Future<String> getServerKeyToken() async{
    final scopes = [
      'https://www.googleapis.com/auth/firebase.messaging'
    ];
    final client = await clientViaServiceAccount(ServiceAccountCredentials.fromJson(
        {
          "type": "service_account",
          "project_id": "britebox-d4790",
          "private_key_id": "a958004ca3325825b682e295cb0a304a8db9bb47",
          "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCzF/FhNbJgyfVz\ndFeIfphYZf7SJBK9gwfUikxd6CmX3NEmk42xpJITuyrPcixtZl+O/s4Jiq6FWYg6\nsATJHSuTmKx6NAf1WhJNoQrkOZ9qfB3iFsemvAJLw/qbIVHNDclj4Cz+gWbS6FxH\nq35Bj8QYqH5U7z5THKc9f6XzPog7yH13zPKBGl06fslUzLbEm33X0ODO0aomJeIC\ne086cNWT3kN2MapNxxC0JNLECmgGCUs9qXp7XP5ML6dBFhKGlGUjEELLufurCzYP\nJZO6q+CZ8Xz1RVDVtJi621/miqC4x+MvqI2VqApBw52WczXTCqnHrIYWqR9W8Kyl\nHBfaot+JAgMBAAECggEADT1u5d3fYxJrJ+7o7blWL+rSbNyn2gTO1mKnBKY+NPDp\nMW3lIsXk2rqSjqWFLU1NMTgbKU9sWYVl8djDcc7LQu0diyc/k17mTYDjWj38UBX+\n65D9j5EEpm9FnqRW9M7ZHZ4cFXChlmQBNncyLUyglaYXONY7CE/s+Tnvncz4q1qm\nUjefrwZ5kstwYxFTtTaWFQR50uVOpq5+yleAGqzPgjqt8eaP+cyj2EMQMKT9iXPv\nulmyHewwcO8/bFMAxS+aQKMOSvap+89IjAp5KmvL+WQr409HOlD/cLcA4RZPI599\nmZee9R4WxH7dr2UHPSw0x/73YzOab2T6sNjQBEGk9QKBgQDnkjIsMVRVCGoVqXf8\n693oThQWpJWR4JVd786vF8KgKWxBWvssgB2sHoSTWE9iwY1675TLYd+saCAgIUmO\nT9rzwoBrFdnw+qA2i40rRn8tc3GnjcZmrH/JNvOi2IjDOu4EltmUHj2wcTVM5KBV\nu7+lfW9loA/5KOZQmVKLFIyCmwKBgQDF/IoHvlrl1jHpYPNAcwMM64LVt4Q+GrSG\nxrsUXqf2zPptOycsyJwLMBOELbBxglT33ZD8r5YHYf1wNxPyyy3tbZi5HcHEtOUk\nAgkZuxXM0dhgFBvQqWEaCDAl4WbuquN5aGWxMqu3rUeOPLJzwzRMgkKnj6TYdI6p\nTenyYKgGqwKBgQCG678f0H36LTTh+iNW0XYxa4x4xNwAaoGcgaRCj+1ts7THP2Mo\nwlyHdCB6WPGn8G2mOwDOnu/bW6+cCMj6ibxgWerIearJpLzECvrtQ93FdYW6wffe\nypKJgeLh9pd4aFVVhy6uBhCbRNpxOqPQT9uRaEwHQgMMgK/wNeTJ8+cKEQKBgCJ0\nUV0Jnm3y+ZqgmZR0r2o3LfydRDE+mn395Z6k3lwPzeDmc2nSu30i77KH9PW79adw\n8oNW1ygPwHgfzaPqAeMYuIQ2jnr59ApxJD5LFX8gYaROu4xzfYd3N1HQSQZtzMpb\nBZ9xrvp2+EXjgDavGNHbtVfNoqVcm1sRSQ46DeOjAoGAKTiQ/aEbGNsAKTrYu/Vo\nb7EMV4iB1k1Mfuf/AbsE21k77haF/q9V5N/CxjoKFHufESVQu8+ienp5AWrKduHh\nNUnfVNnCdmUXR/WOfGRnas8etl8UfqsHoX0bYpjishr4od8aoN+xPkqqk8LvRSZW\nnAzVKMdoHTqKvDdAT9J+1pE=\n-----END PRIVATE KEY-----\n",
          "client_email": "firebase-adminsdk-s74eq@britebox-d4790.iam.gserviceaccount.com",
          "client_id": "103934490760808585266",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-s74eq%40britebox-d4790.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }

    ), scopes);
    final accessServerKey = client.credentials.accessToken.data;
    return accessServerKey;

  }
}