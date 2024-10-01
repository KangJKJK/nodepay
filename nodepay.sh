#!/bin/bash

# 색깔 변수 정의
BOLD="\033[1m"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Nodepay 스크립트를 시작합니다...${NC}"
read -p "해당 노드를 구동하기 위해서는 Proxy가 필수로 필요합니다. 엔터를 누르세요: " 

# 작업 디렉토리 설정
work="/root/nodepay-proxy"

# 기존 작업 디렉토리가 존재하면 삭제
if [ -d "$work" ]; then
    echo -e "${YELLOW}작업 디렉토리 '${work}'가 이미 존재하므로 삭제합니다.${NC}"
    rm -rf "$work"
fi

# 파일 다운로드 및 덮어쓰기
echo -e "${YELLOW}필요한 파일들을 다운로드합니다...${NC}"

# Git 설치
echo -e "${YELLOW}Git을 설치합니다...${NC}"
sudo apt install -y git

# 존재하는 파일을 삭제하고 다운로드
echo -e "${YELLOW}Git 저장소 클론 중...${NC}"
git clone https://github.com/KangJKJK/nodepay-proxy "$work"

# NVM 설치 여부 확인
if ! command -v nvm &> /dev/null
then
    echo "nvm이 설치되어 있지 않습니다. nvm을 설치합니다."

    # nvm 설치
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

    # 셸 환경 파일 로드 (.bashrc 혹은 .zshrc)
    if [ -f ~/.bashrc ]; then
        source ~/.bashrc
    elif [ -f ~/.zshrc ]; then
        source ~/.zshrc
    fi

    echo "nvm 설치 완료."
else
    echo "nvm이 이미 설치되어 있습니다."
fi

# nvm을 로드할 수 있도록 명시적으로 설정
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# 최신 버전 Node.js 설치 및 사용
echo "최신 버전의 Node.js를 설치하고 사용합니다."
nvm install node
nvm use node
npm install node-fetch log4js uuid https-proxy-agent

# 작업 디렉토리 이동
echo -e "${YELLOW}작업 디렉토리로 이동합니다...${NC}"
cd "$work"

# 프록시 입력받기
echo -e "${YELLOW}보유하신 모든 Proxy를 chatgpt에게 다음과 같은 형식으로 변환해달라고 하세요.${NC}"
echo -e "${YELLOW}이러한 형태로 각 프록시를 한줄에 하나씩 입력하세요: http://username:password@proxy_host:port${NC}"
echo -e "${YELLOW}프록시 입력 후 엔터를 두번 누르면 됩니다.${NC}"
> proxy.txt  # proxy.txt 파일 초기화

while true; do
    read -r proxy
    if [ -z "$proxy" ]; then
        break
    fi
    echo "$proxy" >> proxy.txt
done

# np토큰 받기
echo -e "${YELLOW}다음 사이트에 접속하세요: https://app.nodepay.ai/login${NC}"
echo -e "${YELLOW}F12를 누른 후 상단바에서 콘솔로 이동한 후 다음 명령어를 입력하세요: localStorage.getItem('np_token');${NC}"
read -p "콘솔창에 출력되는 값을 모두 복사해서 붙여넣으세요. 따옴표는 제거하세요.: " nptoken

# userid 받기
echo -e "${YELLOW}상단바에서 네트워크로 ms라고 표시되는 창을 클릭하세요.${NC}"
echo -e "${YELLOW}좌측하단에 Name란이 생기면서 Device가 나올겁니다. 아무거나 클릭하세요.${NC}"
echo -e "${YELLOW}우측하단에 Response로 바꿔줍니다. 공용IP와 userid 등이 여기에 노출이됩니다.${NC}"
read -p "userid를 따옴표를 제거하고 입력하세요.: " userid

# 환경변수로 설정
export nptoken="$nptoken"
export userid="$userid"

# nodepay 설치
echo -e "${GREEN}nodepay 스크립트를 실행합니다...${NC}"
sudo node /root/nodepay-proxy/main.js

echo -e "${GREEN}모든 작업이 완료되었습니다. 컨트롤+A+D로 스크린을 종료해주세요.${NC}"
echo -e "${GREEN}스크립트 작성자: https://t.me/kjkresearch${NC}"
