# redis는 0~15번까지의 database로 구성
select [db번호]

# 데이터베이스 내 모든 키 조회
keys *

############ String 자료 구조
# 일반적인 String 구조
set user:email:1 hong1@naver.com

# nx : 이미 존재하면 pass, 없으면 set
set user:email:2 hong2@naver.com nx

# ex(expiration) : 만료시간(초단위), ttl(time to live)
set user:email:3 hong3@naver.com ex 10

# redis활용 : 사용자 인증정보 저장(ex-refresh토큰)
set user:1:refresh_token dshjkqbcwjdh01md ex 100000

# 특정 key 삭제
del user:email:1
# 모든 자료구조 삭제
flushdb

############ string 활용(동시성 이슈, 캐싱처리)
# ★ Redis 명령어로 작성했지만 애플리케이션 프레임워크에서 사용하는 Redis 라이브러리의
# 함수나 메소드들이 하기 명령어들을 날려준다.
# redis 활용 : 좋아요 기능 구현 (rdb경우 -> 동시성이슈) [좋아요를 받은 개수]
# 문제점 : 같은 사용자가 계속 좋아요를 누른다면?
# 해결방안 -> 좋아요 개수는 set 자료구조의 개수를 세는것이 더 좋음
set likes:posting:1 0 # set likes:posting:1 "0" [동일하게 동작]
incr likes:posting:1
decr likes:posting:1
get likes:positing:1

# redis 활용 : 재고관리
set stocks:product:1 100
decr stocks:product:1
get stocks:product:1

# redis 활용 : 캐싱(임시저장) 기능 구현
# 주로 JSON 형태로 저장됨.
set posting:1 "{ \"title\": \"hello java\", \"content\":\"hello java is ...\", \"author_email\":\"hong@naver.com\" }" ex 100
get posting:1

############ List 자료구조 : redis 의 List는 Deque 자료구조
# lpush : 데이터를 왼쪽 끝에 삽입
# rpush : 데이터를 오른쪽 끝에 삽입
# lpop : 데이터를 왼쪽에서 꺼내기
# rpop : 데이터를 오른쪽에서 꺼내기
lpush hongildongs hong1
lpush hongildongs hong2
rpush hongildongs hong3
lrange hongildongs 0 -1
rpop hongildongs # pop 명령어의 경우는 대기열 같은거에 사용.
lpop hongildongs

# list 조회
# -1은 리스트의 끝자리(마지막index)를 의미 -2는 끝에서 2번째를 의미
lrange hongildongs 0 0 #첫번째 값만 조회
lrange hongildongs -1 -1 #마지막 값만 조회
lrange hongildongs -2 -1 #마지막 2번째에서 마지막자리까지.
lrange hongildongs 0 1 # 첫번째에서 2번째 값까지
# 데이터 개수 조회
llen hongildongs
# ttl 적용
expire hongildongs 20
# ttl 조회
ttl hongildongs

# redis List 활용 : 최근 방문한 페이지, 최근 조회한 상품목록 -> 실제로는 zset이 더 유용.[중복 제거, 순서보장]
rpush mypages www.naver.com
rpush mypages www.google.com
rpush mypages www.daum.net
rpush mypages www.chatgpt.com
rpush mypages www.daum.com

# 최근방문한 페이지 3개만 보여주기
lrange mypages -3 -1

############ set자료구조 : 중복없음. 순서없음.
sadd memberlist member1
sadd memberlist member1
sadd memberlist member2

# set 조회
smembers memberlist

# set 요소의 개수 조회
scard memberlist

# set 에서 요소 제거
srem memberlist member2

# 특정 요소가 set안에 들어가있는지 확인
sismember memberlist member1
sismember memberlist member2

# redis활용 : 좋아요 기능 구현
sadd likes:posting:1 member1
sadd likes:posting:1 member2
sadd likes:posting:1 member1

# 좋아요 요소 개수 (좋아요 수 중복없이 계산)
scard likes:posting:1

# 좋아요 눌렀는지 안눌렀는지 확인
sismember likes:posting:1 member1

## 특정 시간 후 삭제 + 중복방지에 사용. (expire)
# 특정 기간 동안만 유효한 이벤트 게시물의 좋아요 목록 (set 과 ttl)
sadd likes:event:123 member1
expire likes:event:123 86400

# 제한 시간이 있는 특별 권한 사용자 목록
sadd premium:users user1 user2
expire premium:users 2592000

############ zset : Sorted Set
# add 시점에 Score 부여, Score기준 정렬
zadd memberlist 3 member1
zadd memberlist 4 member2
zadd memberlist 1 member3
zadd memberlist 2 member4

# 조회방법 : 기본적으로 score 기준 오름차순
zrange memberlist 0 -1

# 내림차순 정렬
zrevrange memberlist 0 -1

# zset 요소 삭제
zrem memberlist member4

# zrank : 특정 멤버가 몇 번째에 존재하는지 확인(오름차순)
zrank memberlist member2

# zrevrank : 특정 멤버가 몇 번째에 존재하는지 확인(내림차순)
zrevrank memberlist member1

# redis zset 활용 : 최근 본 상품목록
# zset을 활용해서 최근시간순으로 score를 설정하여 정렬
zadd recent:products 151930 pineapple
zadd recent:products 152030 banana
zadd recent:products 152130 orange
zadd recent:products 152230 apple
# zset 도 set이므로 같은 상품의 add는 시간만 업데이트 중복제거
zadd recent:products 152330 apple

# 최근 본 상품목록 3개조회
zrevrange recent:products 0 2
zrevrange recent:products 0 -1 withscores

### z활용 분야
# 주식, 코인 등의 실시간 시세 저장

############ hash : map형태의 자료구조, value값이 {key:value, key:value ...} 형태로 구성
# Redis hash 는 1단계 깊이만 제공한다.
hset member:info:1 name hong email hong@naver.com age 30

# 특정 요소 조회
hget member:info:1 name
hget member:info:1 email
hget member:info:1 age

# 모든 요소 조회
hgetall member:info:1

# 요소 수정
hset member:info:1 name kim # 키에 해당하는 값 수정
hincrby member:info:1 age 3 # 숫자인 경우 증감
hincrby member:info:1 age -3
# redis hash 활용 예시 : 빈번하게 변경되는 객체값 캐싱.
# json 형태의 문자열로 캐싱을 할 경우, 해당 문자값을 수정할 때 문자열을 파싱하여 통째로 변경해야함.

# 요소 삭제
hdel member:info:1 age
# 여러 필드 동시 삭제
hdel user:1 age city email

############ pub, sub : Redis 에서 제공하는 기능 (채팅, 알림서비스 특화)
# 메세지 발행 및 구독 서비스
# 동일한 채널을 여러 구독자가 구독할때, 해당 채널로 발행된 메세지가 모든 구독자에게 발송되는 기능 구현시 유용

# 구독 서버 (가정: power shell 터미널 1,2)
subscribe test_channel
# 발행 서버 (가정: cmd)
publish test_channel "hello, This is test message"

# redis stream 실습 : 데이터를 실시간으로 read, 데이터가 저장
# * : 고유 ID값 자동 생성
xadd test_stream * message  "hello this is stream message"
# block 유지 시간 설정
# $ : 마지막 메세지 이후에 오는 새 메세지를 의미
xread block 20000 streams test_stream $
# 전체 메세지 조회 -(시작 범위) + (맨 끝 범위)
xrange test_stream - +


