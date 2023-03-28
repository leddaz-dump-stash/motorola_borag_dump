#!/system/bin/sh

PROP_BUGREPORT_FOLDER=vendor.ontim.ut_bugreport.folder
DEST_DIR=$(getprop $PROP_BUGREPORT_FOLDER)

Log() {
    log -p d -t OntimUT20220824 $1
}

Log " >>> ut_bugreport --- $PROP_BUGREPORT_FOLDER=$DEST_DIR"

if [ ! "$DEST_DIR" ]; then
   Log " <<< Exit for EMPTY $PROP_BUGREPORT_FOLDER"
   exit
fi

DIR_BUGREPORTS=/bugreports
#DIR_BUGREPORTS=/data/user_de/0/com.android.shell/files/bugreports

if [ "$DEST_DIR" = "ClearBugreports" ]; then
    Log " - OntimUT - Clear $DIR_BUGREPORTS ---"
    rm -rf $DIR_BUGREPORTS/*
    exit
fi

Log "`date +%Y-%m-%d-%H-%M-%S` ... Taking Bugreport ... $DEST_DIR"

move_files() {
    dest_folder="$1"
    input_files="$2"
    file_label="$3"

    for f in $input_files; do
        Log "$file_label ** bugreport file:\n - $f"
        `mv $f $destFolder`
    done
}

move_dumpstate_log_file() {
    fileNameLike="$1"
    destFolder="$2"

    txt_files=`ls $DIR_BUGREPORTS/bugreport-*.txt -1 | grep "dumpstate_log" | grep "$fileNameLike"`
    if [ ! "$txt_files" ]; then
        Log " >>> Copy bugreport dumpstate_log files to $DEST_DIR"
        cp $DIR_BUGREPORTS/bugreport-*.txt $destFolder
    else
        Log " -- Move bugreport dumpstate log file(s) to $DEST_DIR -- "
        move_files $destFolder $txt_files "dumpstate_log"
    fi
}

move_zip_file() {
    fileNameLike="$1"
    destFolder="$2"

    zip_files=`ls $DIR_BUGREPORTS/bugreport-*.zip | grep "$fileNameLike"`
    if [ ! "$zip_files" ]; then
        Log " >>> Copy bugreport zip files to $DEST_DIR"
        cp $DIR_BUGREPORTS/bugreport-*.zip $destFolder
    else
        Log " -- Move bugreport zip file(s) to $DEST_DIR -- "
        move_files $destFolder $zip_files "ZIP"
    fi
}

move_screenshot_file() {
    fileNameLike="$1"
    destFolder="$2"

    screenshot_files=`ls $DIR_BUGREPORTS/screenshot-*.png | grep "$fileNameLike"`
    if [ ! "$screenshot_files" ]; then
        Log " >>> Copy bugreport screenshot files to $DEST_DIR"
        cp $DIR_BUGREPORTS/screenshot-*.png $destFolder
    else
        Log " -- Move bugreport screenshot file(s) to $DEST_DIR -- "
        move_files $destFolder $screenshot_files "Screenshot"
    fi
}

START_TIME=$SECONDS
FILE_NAME_LIKE=$(date +%Y-%m-%d-%H-%M-%S)

sleep 2
Log "Waiting - Search $FILE_NAME_LIKE.tmp file in /bugreports/"

while :
do
    files=`ls $DIR_BUGREPORTS/*.tmp | grep "$FILE_NAME_LIKE" 2> /dev/null | wc -l`
    if [ $files -ne 0 ]; then
        sleep 1
        #Log "$FILE_NAME_LIKE.tmp file exists"
    else
        Log "No $FILE_NAME_LIKE.tmp file! bugreport done?!"
        break
    fi
done

ELAPSED_TIME=$(($SECONDS - $START_TIME))
if [ $ELAPSED_TIME -lt 3 ]; then
    while :
    do
        files=`ls $DIR_BUGREPORTS/*.tmp 2> /dev/null | wc -l`
        if [ $files -ne 0 ]; then
            sleep 1
        else
            break
        fi
    done
    ELAPSED_TIME=$(($SECONDS - $START_TIME))
fi
Log "Bugreport consumed time: $(($ELAPSED_TIME/60)):$(($ELAPSED_TIME%60))"

files=`ls $DIR_BUGREPORTS/ -1 | grep "$FILE_NAME_LIKE"`
if [ ! "$files" ]; then
    files=`ls $DIR_BUGREPORTS/ -1`
fi
Log "bugreport files:\n$files"

if [ -n "$files" ]; then
    mkdir -p $DEST_DIR

    move_dumpstate_log_file $FILE_NAME_LIKE $DEST_DIR
    move_zip_file $FILE_NAME_LIKE $DEST_DIR
    move_screenshot_file $FILE_NAME_LIKE $DEST_DIR

    Log "$FILE_NAME_LIKE  >>> Bugreport DONE! >>> "
    Log $DEST_DIR
else
    Log " *** Failed to generate bugreport?! ***"
fi

