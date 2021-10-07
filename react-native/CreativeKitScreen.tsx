import {CreativeKit} from '@snapchat/snap-kit-react-native';
import React, {useState} from 'react';
import {
  Button,
  Image,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from 'react-native';
// @ts-ignore typescript definitions don't exist for this
import ImgToBase64 from 'react-native-image-base64';
import {launchCamera, launchImageLibrary} from 'react-native-image-picker';
import RNFetchBlob from 'rn-fetch-blob';

const CollapsibleSection = ({
  children,
  title,
  collapsible = true,
}: {
  children?: JSX.Element | JSX.Element[] | null;
  title: string;
  collapsible?: boolean;
}) => {
  const [hidden, setHidden] = useState<boolean>(false);

  return (
    <View style={{width: '100%', paddingVertical: 10}}>
      <View
        style={{
          width: '100%',
          flexDirection: 'row',
          justifyContent: 'center',
          borderBottomWidth: 1,
        }}>
        <Text
          style={{
            marginLeft: collapsible ? 'auto' : undefined,
            fontWeight: 'bold',
          }}>
          {title}
        </Text>
        {collapsible && (
          <TouchableOpacity
            style={{marginLeft: 'auto'}}
            onPress={() => setHidden(!hidden)}>
            <Image
              style={{width: 40, height: 40}}
              source={require('./arrow.png')}
            />
          </TouchableOpacity>
        )}
      </View>
      {!hidden && <View style={{padding: 20}}>{children}</View>}
    </View>
  );
};

const isValidHttpUrl = (url: string) => {
  let test;
  try {
    test = new URL(url);
  } catch (_) {
    return false;
  }

  return url.startsWith('https:') || url.startsWith('http:');
};

export default function CreativeKitScreen() {
  const [photoUrl, setPhotoUrl] = useState<string>('');
  const [videoUrl, setVideoUrl] = useState<string>('');
  const [stickerUrl, setStickerUrl] = useState<string>('');
  const [lensUUID, setLensUUID] = useState<string>('');
  const [captionText, setCaptionText] = useState<string>('');
  const [attachmentUrl, setAttachmentUrl] = useState<string>('');
  const [sharePhotoError, setSharePhotoError] = useState<string | null>(null);
  const [shareVideoError, setShareVideoError] = useState<string | null>(null);
  const [shareLensError, setShareLensError] = useState<string | null>(null);
  const [sharePreviewError, setSharePreviewError] = useState<string | null>(
    null,
  );

  const [launchDataKeys, setLaunchDataKeys] = useState<Record<number, string>>(
    {},
  );
  const [launchDataValues, setLaunchDataValues] = useState<
    Record<number, string>
  >({});
  const [countLaunchData, setCountLaunchData] = useState<number>(1);

  const generateLaunchDataJSON = () => {
    const launchData: Record<string, string> = {};

    for (let i = 0; i < countLaunchData; i++) {
      if (launchDataKeys[i] && launchDataValues[i]) {
        launchData[launchDataKeys[i]] = launchDataValues[i];
      }
    }

    return Object.keys(launchData).length === 0 ? null : launchData;
  };

  const LaunchDataElements: any = [];
  for (let i = 0; i < countLaunchData; i++) {
    LaunchDataElements.push(
      <View
        key={i}
        style={{
          flexDirection: 'row',
          width: '100%',
          justifyContent: 'center',
          alignItems: 'center',
        }}>
        <TextInput
          onChangeText={(text) => {
            setLaunchDataKeys({...launchDataKeys, [i]: text});
          }}
          value={launchDataKeys[i]}
          placeholder="Enter key"
          placeholderTextColor="gray"
          numberOfLines={1}
          style={{borderWidth: 1, padding: 5, flex: 0.5, margin: 5}}
        />
        <TextInput
          onChangeText={(text) => {
            setLaunchDataValues({...launchDataValues, [i]: text});
          }}
          value={launchDataValues[i]}
          placeholder="Enter value"
          placeholderTextColor="gray"
          numberOfLines={1}
          style={{borderWidth: 1, padding: 5, flex: 0.5, margin: 5}}
        />
        {countLaunchData !== 1 && (
          <TouchableOpacity
            onPress={() => {
              const launchDataKeysCopy = launchDataKeys;
              const launchDataValuesCopy = launchDataValues;

              delete launchDataKeysCopy[i];
              delete launchDataValuesCopy[i];
              setLaunchDataKeys(launchDataKeysCopy);
              setLaunchDataValues(launchDataValuesCopy);
              setCountLaunchData(countLaunchData - 1);
            }}>
            <Text>{'❌'}</Text>
          </TouchableOpacity>
        )}
      </View>,
    );
  }

  const sharePhoto = (url: string) => {
    CreativeKit.sharePhoto({
      content: {
        uri: url,
      },
      ...(stickerUrl.trim() !== '' && {
        sticker: {
          uri: stickerUrl,
          width: 200,
          height: 200,
          posX: 0.5,
          posY: 0.5,
        },
      }),
      ...(attachmentUrl.trim() !== '' && {attachmentUrl}),
      ...(captionText.trim() !== '' && {caption: captionText}),
    }).catch((error) => {
      setSharePhotoError(error.toString());
    });
  };

  const shareVideo = (url: string) => {
    CreativeKit.shareVideo({
      content: {
        uri: url,
      },
      ...(stickerUrl.trim() !== '' && {
        sticker: {
          uri: stickerUrl,
          width: 200,
          height: 200,
          posX: 0.5,
          posY: 0.5,
        },
      }),
      ...(attachmentUrl.trim() !== '' && {attachmentUrl}),
      ...(captionText.trim() !== '' && {caption: captionText}),
    }).catch((error) => setShareVideoError(error.toString()));
  };

  return (
    <KeyboardAvoidingView
      style={{flex: 1, flexDirection: 'column', justifyContent: 'center'}}
      behavior="padding"
      enabled={Platform.OS === 'ios'}
      keyboardVerticalOffset={100}>
      <ScrollView style={{padding: 20}}>
        <CollapsibleSection title={'Share Photo to Snapchat'}>
          <View
            style={{
              flexDirection: 'row',
              justifyContent: 'space-between',
            }}>
            <View>
              <View style={{marginBottom: 15}}>
                <Button
                  title={'Launch Camera'}
                  onPress={() => {
                    launchCamera({mediaType: 'photo'}, (response) => {
                      if (response?.assets?.[0]?.uri) {
                        setPhotoUrl(response.assets[0].uri);
                      }
                    });
                  }}
                />
              </View>
              <Button
                title={'Launch Gallery'}
                onPress={() => {
                  launchImageLibrary({mediaType: 'photo'}, (response) => {
                    if (response?.assets?.[0]?.uri) {
                      setPhotoUrl(response.assets[0].uri);
                    }
                  });
                }}
              />
            </View>
            <TextInput
              value={photoUrl}
              onChangeText={(text) => setPhotoUrl(text)}
              placeholder="Enter Photo URL"
              placeholderTextColor="gray"
              numberOfLines={1}
              style={{
                borderWidth: 1,
                padding: 5,
                width: '50%',
                height: '50%',
              }}
            />
          </View>

          <Text style={{color: 'red'}}>{sharePhotoError ?? ''}</Text>

          <View
            style={{
              flex: 1,
              flexDirection: 'row',
              width: '100%',
              justifyContent: 'space-between',
            }}>
            <Button
              title={'Share Photo'}
              onPress={() => {
                setSharePhotoError(null);

                if (isValidHttpUrl(photoUrl)) {
                  RNFetchBlob.config({
                    fileCache: true,
                    appendExt: 'png',
                  })
                    .fetch('GET', photoUrl)
                    .then((res) => {
                      sharePhoto(`file://${res.data}`);
                    });
                } else {
                  sharePhoto(photoUrl);
                }
              }}
            />

            <Button
              title={'Share Photo (raw)'}
              onPress={() => {
                setSharePhotoError(null);
                ImgToBase64.getBase64String(photoUrl)
                  .then((base64String: string) => {
                    CreativeKit.sharePhoto({
                      content: {
                        raw: base64String,
                      },
                      ...(stickerUrl.trim() !== '' && {
                        sticker: {
                          uri: stickerUrl,
                          width: 200,
                          height: 200,
                          posX: 0.5,
                          posY: 0.5,
                        },
                      }),
                      ...(attachmentUrl.trim() !== '' && {attachmentUrl}),
                      ...(captionText.trim() !== '' && {
                        caption: captionText,
                      }),
                    }).catch((error) => {
                      setSharePhotoError(error.toString());
                    });
                  })
                  .catch(() => setSharePhotoError('Invalid photo data.'));
              }}
            />
          </View>
        </CollapsibleSection>

        <CollapsibleSection title={'Share Video to Snapchat'}>
          <View
            style={{
              flexDirection: 'row',
              justifyContent: 'space-between',
            }}>
            <View>
              <View style={{marginBottom: 15}}>
                <Button
                  title={'Launch Camera'}
                  onPress={() => {
                    launchCamera({mediaType: 'video'}, (response) => {
                      if (response?.assets?.[0]?.uri) {
                        setVideoUrl(response.assets[0].uri);
                      }
                    });
                  }}
                />
              </View>
              <Button
                title={'Launch Gallery'}
                onPress={() => {
                  launchImageLibrary({mediaType: 'video'}, (response) => {
                    if (response?.assets?.[0]?.uri) {
                      setVideoUrl(response.assets[0].uri);
                    }
                  });
                }}
              />
            </View>
            <TextInput
              value={videoUrl}
              onChangeText={(text) => setVideoUrl(text)}
              placeholder="Enter Video URL"
              placeholderTextColor="gray"
              numberOfLines={1}
              style={{
                borderWidth: 1,
                padding: 5,
                width: '50%',
                height: '50%',
              }}
            />
          </View>

          <Text style={{color: 'red'}}>{shareVideoError ?? ''}</Text>

          <Button
            title={'Share Video'}
            onPress={() => {
              setShareVideoError(null);
              if (isValidHttpUrl(videoUrl)) {
                RNFetchBlob.config({
                  fileCache: true,
                  appendExt: 'mp4',
                })
                  .fetch('GET', videoUrl)
                  .then((res) => {
                    shareVideo(`file://${res.data}`);
                  });
              } else {
                shareVideo(videoUrl);
              }
            }}
          />
        </CollapsibleSection>

        <CollapsibleSection title={'Share Lens to Snapchat'}>
          <TextInput
            value={lensUUID}
            onChangeText={(text) => setLensUUID(text)}
            placeholder="Enter Lens UUID"
            placeholderTextColor="gray"
            numberOfLines={1}
            style={{borderWidth: 1, padding: 5}}
          />
          <Text style={{alignSelf: 'center', margin: 10}}>
            {'Launch Data (Optional)'}
          </Text>
          {LaunchDataElements}
          <Button
            title={'Add more'}
            onPress={() => {
              setCountLaunchData(countLaunchData + 1);
            }}
          />
          <Text style={{color: 'red'}}>{shareLensError ?? ''}</Text>
          <Button
            title={'Share Lens to Camera Preview'}
            onPress={() => {
              setShareLensError(null);
              const launchData = generateLaunchDataJSON();
              CreativeKit.shareLensToCameraPreview({
                lensUUID,
                ...(launchData && {launchData}),
                ...(attachmentUrl.trim() !== '' && {attachmentUrl}),
                ...(captionText.trim() !== '' && {caption: captionText}),
              }).catch((error) => setShareLensError(error.toString()));
            }}
          />
        </CollapsibleSection>

        <CollapsibleSection title={'Share to Snapchat Camera Preview'}>
          <Text style={{color: 'red'}}>{sharePreviewError ?? ''}</Text>
          <Button
            title={'Share to Camera Preview'}
            onPress={() => {
              setSharePhotoError(null);
              CreativeKit.shareToCameraPreview({
                ...(stickerUrl.trim() !== '' && {
                  sticker: {
                    uri: stickerUrl,
                    width: 200,
                    height: 200,
                    posX: 0.5,
                    posY: 0.5,
                  },
                }),
                ...(attachmentUrl.trim() !== '' && {attachmentUrl}),
                ...(captionText.trim() !== '' && {caption: captionText}),
              }).catch((error) => setSharePreviewError(error.toString()));
            }}
          />
        </CollapsibleSection>
        <CollapsibleSection collapsible={false} title={'Optional Metadata'}>
          <View
            style={{
              flexDirection: 'row',
              justifyContent: 'space-between',
            }}>
            <View>
              <View style={{marginBottom: 15}}>
                <Button
                  title={'Launch Camera'}
                  onPress={() => {
                    launchCamera(
                      {mediaType: 'photo', quality: 0.2},
                      (response) => {
                        if (response?.assets?.[0]?.uri) {
                          setStickerUrl(response.assets[0].uri);
                        }
                      },
                    );
                  }}
                />
              </View>
              <Button
                title={'Launch Gallery'}
                onPress={() => {
                  launchImageLibrary(
                    {mediaType: 'photo', quality: 0.2},
                    (response) => {
                      if (response?.assets?.[0]?.uri) {
                        setStickerUrl(response.assets[0].uri);
                      }
                    },
                  );
                }}
              />
            </View>
            <TextInput
              value={stickerUrl}
              onChangeText={(text) => setStickerUrl(text)}
              placeholder="Enter Sticker URL"
              placeholderTextColor="gray"
              numberOfLines={1}
              style={{
                borderWidth: 1,
                padding: 5,
                width: '50%',
                height: '50%',
              }}
            />
          </View>

          <TextInput
            value={captionText}
            onChangeText={(text) => setCaptionText(text)}
            placeholder="Enter caption text"
            placeholderTextColor="gray"
            numberOfLines={1}
            style={{borderWidth: 1, padding: 5, marginVertical: 10}}
          />

          <TextInput
            value={attachmentUrl}
            onChangeText={(text) => setAttachmentUrl(text)}
            placeholder="Enter attachment url"
            placeholderTextColor="gray"
            numberOfLines={1}
            style={{borderWidth: 1, padding: 5}}
          />
        </CollapsibleSection>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}
