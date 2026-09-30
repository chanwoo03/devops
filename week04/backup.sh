#!/bin/bash
# ============================================
# 백업스크립트
# 사용법: ./backup.sh [백업할_폴더]
# ============================================
cd "$(dirname "$0")" || exit 1
SOURCE_DIR=${1:-test} # 인자없으면test 디렉터리
BACKUP_DIR="backups"
TODAY=$(date +%Y%m%d_%H%M%S)
FILENAME="${TODAY}_$$.tar.gz" # 이름충돌가능성줄이기
# $$: 현재셀의PID
# 1) 원본확인
if [ ! -d "$SOURCE_DIR" ]; then
echo "오류: '$SOURCE_DIR' 디렉터리가없습니다."
exit 1
fi
# 2) 백업폴더준비
mkdir -p "$BACKUP_DIR" || exit 1
# 3) 압축
echo "백업시작: $SOURCE_DIR → $BACKUP_DIR/$FILENAME"
tar -czf "$BACKUP_DIR/$FILENAME" "$SOURCE_DIR"
# 4) 결과확인
if [ $? -eq 0 ]; then
SIZE=$(du -sh"$BACKUP_DIR/$FILENAME" | cut -f1)
echo "백업완료! (크기: $SIZE)"
else
echo "백업실패"
exit 1
fi
# 5) 목록
echo "현재보관중인백업:"
ls -1 "$BACKUP_DIR" # 한줄에하나씩출력

