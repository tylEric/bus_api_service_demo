# Bus service template

目前先定下結構，功能尚未完全實作：
* 一個 scheduler 定時去爬縣市各站到站公車資訊，在用此資訊找到該發通知的使用者並發送通知
* 通知暫時使用 in process default queue 實作，實務應以 redis + sidekiq / pubsub 等工具取代
* 查詢某路公車各站資訊（韓到站資訊）、訂閱 / 取消訂閱 API
* 快取功能先以 global hash var 代替，實務應以快取工具如 redis 取代
* 維護兩張快取的表，一個紀錄某路某方向公車應通知的使用者、另一紀錄應發通知的站（被訂閱站的前三站）及對應前表的 key
