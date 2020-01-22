package com.snapchat.kit.creativesample;

import com.snapchat.kit.sdk.SnapCreative;
import com.snapchat.kit.sdk.creative.api.SnapCreativeKitApi;
import com.snapchat.kit.sdk.creative.exceptions.SnapMediaSizeException;
import com.snapchat.kit.sdk.creative.exceptions.SnapStickerSizeException;
import com.snapchat.kit.sdk.creative.exceptions.SnapVideoLengthException;
import com.snapchat.kit.sdk.creative.media.SnapMediaFactory;
import com.snapchat.kit.sdk.creative.media.SnapSticker;
import com.snapchat.kit.sdk.creative.models.SnapContent;
import com.snapchat.kit.sdk.creative.models.SnapLiveCameraContent;
import com.snapchat.kit.sdk.creative.models.SnapPhotoContent;
import com.snapchat.kit.sdk.creative.models.SnapVideoContent;

import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.MediaPlayer;
import android.net.Uri;
import android.provider.MediaStore;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.Toast;
import android.widget.VideoView;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

public class MainActivity extends AppCompatActivity {

    public enum SnapState {
        NO_SNAP("Clear Snap"),
        IMAGE("Select Image"),
        VIDEO("Select Video");

        private String mOptionText;

        SnapState(String optionText) {
            mOptionText = optionText;
        }

        public String getOptionText() {
            return mOptionText;
        }

        public int getRequestCode() {
            return ordinal();
        }
    }


    private static final String SNAP_NAME = "snap";
    private static final String STICKER_NAME = "sticker";

    private SnapState mSnapState = SnapState.NO_SNAP;
    private File mSnapFile;
    private File mStickerFile;

    private ImageView mPreviewImage;
    private VideoView mPreviewVideo;
    private EditText mCaptionField;
    private EditText mUrlField;
    private CompoundButton mSendStickerOption;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        final SnapCreativeKitApi snapCreativeKitApi = SnapCreative.getApi(this);
        final SnapMediaFactory snapMediaFactory = SnapCreative.getMediaFactory(this);

        mSnapFile = new File(getCacheDir(), SNAP_NAME);
        mStickerFile = new File(getCacheDir(), STICKER_NAME);

        mPreviewImage = findViewById(R.id.image_preview);
        mPreviewVideo = findViewById(R.id.video_preview);
        mCaptionField = findViewById(R.id.caption_field);
        mUrlField = findViewById(R.id.url_field);
        mSendStickerOption = findViewById(R.id.send_sticker_option);

        mPreviewVideo.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mp) {
                mp.setLooping(true);
            }
        });

        if (!mStickerFile.exists()) {
            try (InputStream inputStream = getAssets().open("sticker.png")) {
                copyFile(inputStream, mStickerFile);
            } catch (IOException e) {
                mSendStickerOption.setEnabled(false);
                Toast.makeText(this, "Failed to copy sticker asset", Toast.LENGTH_SHORT).show();
            }
        }

        findViewById(R.id.snap_container).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                openMediaSelectDialog();
            }
        });

        findViewById(R.id.share_button).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                try {
                    final SnapContent content;

                    switch (mSnapState) {
                        case IMAGE:
                            content = new SnapPhotoContent(snapMediaFactory.getSnapPhotoFromFile(mSnapFile));
                            break;
                        case VIDEO:
                            content = new SnapVideoContent(snapMediaFactory.getSnapVideoFromFile(mSnapFile));
                            break;
                        case NO_SNAP:
                        default:
                            content = new SnapLiveCameraContent();
                    }

                    if (!TextUtils.isEmpty(mCaptionField.getText())) {
                        content.setCaptionText(mCaptionField.getText().toString());
                    }
                    if (!TextUtils.isEmpty(mUrlField.getText())) {
                        content.setAttachmentUrl(mUrlField.getText().toString());
                    }

                    if (mSendStickerOption.isChecked()) {
                        final SnapSticker snapSticker = snapMediaFactory.getSnapStickerFromFile(mStickerFile);

                        snapSticker.setHeight(300);
                        snapSticker.setWidth(300);
                        snapSticker.setPosX(0.2f);
                        snapSticker.setPosY(0.8f);
                        snapSticker.setRotationDegreesClockwise(345.0f);

                        content.setSnapSticker(snapSticker);
                    }
                    snapCreativeKitApi.send(content);
                } catch (SnapMediaSizeException | SnapVideoLengthException | SnapStickerSizeException e) {
                    Toast.makeText(view.getContext(), "Media too large to share", Toast.LENGTH_SHORT).show();
                }
            }
        });
    }

    @Override
    public void onResume() {
        super.onResume();

        if (mSnapState == SnapState.VIDEO) {
            mPreviewVideo.start();
        }
    }

    @Override
    protected void onActivityResult(
            int requestCode, int resultCode, @Nullable Intent intent) {
        if (requestCode == SnapState.IMAGE.getRequestCode()) {
            handleImageSelect(intent);
        } else if (requestCode == SnapState.VIDEO.getRequestCode()) {
            handleVideoSelect(intent);
        } else {
            super.onActivityResult(requestCode, resultCode, intent);
        }
    }

    private void openMediaSelectDialog() {
        ArrayAdapter<String> adapter = new ArrayAdapter<>(this, android.R.layout.select_dialog_item);

        for (SnapState state : SnapState.values()) {
            adapter.add(state.getOptionText());
        }

        new AlertDialog.Builder(this)
                .setAdapter(adapter, new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        switch (SnapState.values()[which]) {
                            case IMAGE:
                                selectMediaFromGallery("image/*", SnapState.IMAGE.getRequestCode());
                                break;
                            case VIDEO:
                                selectMediaFromGallery("video/*", SnapState.VIDEO.getRequestCode());
                                break;
                            case NO_SNAP:
                                reset();
                        }
                    }
                })
                .show();
    }

    private void selectMediaFromGallery(String mimeType, int resultCode) {
        Intent intent = new Intent(Intent.ACTION_PICK);
        intent.setDataAndType(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, mimeType);

        startActivityForResult(intent, resultCode);
    }

    private void handleImageSelect(@Nullable Intent intent) {
        if (saveContentLocally(intent)) {
            reset();
            try {
                Bitmap bitmap = BitmapFactory.decodeStream(new FileInputStream(mSnapFile));
                mPreviewImage.setImageBitmap(bitmap);
                mSnapState = SnapState.IMAGE;
            } catch (FileNotFoundException e) {
                throw new IllegalStateException("Saved the image file, but it doesn't exist!");
            }
        }
    }

    private void handleVideoSelect(@Nullable Intent intent) {
        if (saveContentLocally(intent)) {
            reset();
            mPreviewVideo.setVideoURI(Uri.fromFile(mSnapFile));
            mPreviewVideo.start();
            mPreviewVideo.setVisibility(View.VISIBLE);
            mSnapState = SnapState.VIDEO;
        }
    }

    private void reset() {
        mPreviewImage.setImageDrawable(null);
        mPreviewVideo.setVisibility(View.GONE);
        mPreviewVideo.setVideoURI(null);
        mSnapState = SnapState.NO_SNAP;
    }

    /**
     * Saves the file from the ACTION_PICK Intent locally to {@link #mSnapFile} to be accessed by our FileProvider
     */
    private boolean saveContentLocally(@Nullable Intent intent) {
        if (intent == null || intent.getData() == null) {
            return false;
        }
        InputStream inputStream;

        try {
            inputStream = getContentResolver().openInputStream(intent.getData());
        } catch (FileNotFoundException e) {
            Toast.makeText(this, "Could not open file", Toast.LENGTH_SHORT).show();
            return false;
        }
        if (inputStream == null) {
            Toast.makeText(this, "File does not exist", Toast.LENGTH_SHORT).show();
            return false;
        }
        try {
            copyFile(inputStream, mSnapFile);
        } catch (IOException e) {
            Toast.makeText(this, "Failed save file locally", Toast.LENGTH_SHORT).show();
            return false;
        }
        return true;
    }

    private static void copyFile(InputStream inputStream, File file) throws IOException {
        byte[] buffer = new byte[1024];
        int length;

        try (FileOutputStream outputStream = new FileOutputStream(file)) {
            while ((length = inputStream.read(buffer)) != -1) {
                outputStream.write(buffer, 0, length);
            }
        }
    }
}
