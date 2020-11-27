#!/bin/bash

################################################################################
DIR_TO_PARSE="$1"

################################################################################

if [[ ! -d "${DIR_TO_PARSE}" ]]
then
  echo "ERROR - ${DIR_TO_PARSE} should exist and be a directory"
  exit 1
fi

[[ -z "$LIST_FILES" ]] && LIST_FILES=`find ${DIR_TO_PARSE} ${FIND_FILE_PATTERN} -type f`

while IFS= read CURRENT_FILE
do

  [[ "${CURRENT_FILE}" != ${DIR_TO_PARSE}/* ]] && CURRENT_FILE=${DIR_TO_PARSE}/${CURRENT_FILE}

	FILE_LOSSLESS="${CURRENT_FILE}-LOSSLESS"
	FILE_RELATIVE_PATH=`echo "${CURRENT_FILE}" | sed -e "s|${DIR_TO_PARSE}/||g"`

  if [[ ! -e "${CURRENT_FILE}" ]]
  then
    echo "IGNORE - ${CURRENT_FILE} does not exist"
    continue

  elif [[ "${CURRENT_FILE}" == *.png ]]
  then
    pngcrush -rem allb -brute "${CURRENT_FILE}" "${FILE_LOSSLESS}" > /dev/null 2>&1
    CMD_STATUS=$?

  elif [[ "${CURRENT_FILE}" == *.gif ]]
  then
    convert "${CURRENT_FILE}" -layers Optimize "${FILE_LOSSLESS}" > /dev/null 2>&1
    CMD_STATUS=$?

  elif [[ "${CURRENT_FILE}" == *.jpeg || "${CURRENT_FILE}" == *.jpg ]]
  then
    jpegtran -copy none -optimize -perfect -outfile "${FILE_LOSSLESS}" "${CURRENT_FILE}" > /dev/null 2>&1
    CMD_STATUS=$?

  else
    continue
  fi

	if [[ ${CMD_STATUS} -eq 0 ]]
	then
		SIZE_ORIGIN=`stat -c '%s' "${CURRENT_FILE}"`
		SIZE_LOSSLESS=`stat -c '%s' "${FILE_LOSSLESS}"`
    OWNER_ORIGIN=`stat -c '%u' "${CURRENT_FILE}"`
    GROUP_ORIGIN=`stat -c '%g' "${CURRENT_FILE}"`
    PERMISSION_ORIGIN=`stat -c '%a' "${CURRENT_FILE}"`

		if [[ ${SIZE_LOSSLESS} -lt ${SIZE_ORIGIN} ]]
		then
      mv "${FILE_LOSSLESS}" "${CURRENT_FILE}"
      chown ${OWNER_ORIGIN}:${GROUP_ORIGIN} "${CURRENT_FILE}"
      chmod ${PERMISSION_ORIGIN} "${CURRENT_FILE}"

			PERCENT_GAIN=`perl -E "say 100*(1-($SIZE_LOSSLESS/$SIZE_ORIGIN))"`

      echo "COMPRESSED - ${FILE_RELATIVE_PATH} compressed with a reduction of `printf "%0.2f" ${PERCENT_GAIN}`%"

		elif [[ ${SIZE_LOSSLESS} -gt ${SIZE_ORIGIN} ]]
		then
			echo "BIGGER - ${FILE_RELATIVE_PATH} seems to be bigger after compression"

		else
			echo "SAME - ${FILE_RELATIVE_PATH} is the same when is compressed"
		fi

	else
		echo "ERROR - ${FILE_RELATIVE_PATH} problem when trying to compress it"
	fi

  [[ -e "${FILE_LOSSLESS}" ]] && rm "${FILE_LOSSLESS}"

done <<< ${LIST_FILES}

exit 0
