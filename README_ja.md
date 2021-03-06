# redmine issue evm

[![Rate at redmine.org](http://img.shields.io/badge/rate%20at-redmine.org-blue.svg?style=flat)](http://www.redmine.org/plugins/redmine_issue_evm)

チケットの開始日、期日、予定工数、作業時間を利用してEVM値の計算とチャートを表示する機能を提供しています。

## バージョン
3.5.8

## 主な機能
* EVM値の計算
* EVM(PV,EV,AC)のチャート表示
* プロジェクト完了予測
* ベースラインの設定、履歴管理
* 未完了のチケットを表示

## オプション
* EVM値を計算する基準日の変更
* パフォーマンス(SPI,CPI,CR)のチャート表示
* プロジェクト完了予測
* ベースラインもしくは、すべてのチケットをもとにしたEVMの計算
* EVM値の説明

## EVM値の計算
各チケット毎に以下の情報を使ってEVM値を計算して集計しています。EVMを表示するプロジェクト(子孫プロジェクト含む)内の、以下のすべての項目に入力があるチケットが計算対象です。

* 開始日
* 期日
* 予定工数(0でも構いませんがPV,EVが計算できないため意味がありません)
* 作業時間

Redmine3.1から親チケットの予定工数が入力可能になったので、チケットの親子関係に関係なくチケット毎にPV,EVを算出しています。

* PV : 開始日、期日、予定工数を利用して、PVを計算します。日毎の工数を計算しています。
* EV : チケットをCLOSEした日に、予定工数をEVとして計算しています。
* AC : PVの計算に使われているチケットの作業時間を使って、ACを計算しています。

## EVMの計算例
開始日:2015/08/01,期日:2015/08/03,予定工数:24.0時間のチケットを作成。この時点では、PVのみが有効。PVは日毎のPVから累積値を計算しています。チケットが完了していないので、EVは計算されません。
* PV -> 8/1:8.0時間 8/2:8.0時間 8/3:8.0時間　(24時間を3日で割って日毎のPVを計算)
* EV -> 0
* AC -> 0

| EVM | 8/1 | 8/2 | 8/3 |
| --- | --- | --- | --- |
| PV  | 8   | 16  | 24  |
| EV  | 0   | 0   | 0   |
| AC  | 0   | 0   | 0   |

チケットの作業時間を8/1,8/2,8/3に10.0時間、6.0時間、7.0時間入力する。日毎のPVに対して、ACの累積値が計算されます。
* PV -> 8/1:8.0時間 8/2:8.0時間 8/3:8.0時間
* EV -> 0
* AC -> 8/1:10.0時間 8/2:6.0時間 8/3:8.0時間

| EVM | 8/1 | 8/2 | 8/3 |
| --- | --- | --- | --- |
| PV  | 8   | 16  | 24  |
| EV  | 0   | 0   | 0   |
| AC  | 10  | 16  | 24  |

チケットを8/3にCLOSEする。チケットのクローズした日がEVの計上日になります。
* PV -> 8/1:8.0時間 8/2:8.0時間 8/3:8.0時間
* EV -> 8/3:24.0時間
* AC -> 8/1:10.0時間 8/2:6.0時間 8/3:8.0時間

| EVM | 8/1 | 8/2 | 8/3 |
| --- | --- | --- | --- |
| PV  | 8   | 16  | 24  |
| EV  | 0   | 0   | 24  |
| AC  | 10  | 16  | 24  |

上記のEVM値をもとに、チャート、EVM指標を計算しています。

## チャートの表示
計算されたEVM値を元に以下のチャートを表示します

##### メインチャート
PV,EV,ACを累積値で時系列に表示します。ベースラインが設定されている場合は、ベースラインも表示します。

##### パフォーマンスチャート
PV,EV,ACが計算されている日だけ、SPI,CPI,CRを計算して表示します。

##### バージョンチャート
バージョンが設定されているチケットがある場合、バージョンごとにPV,EV,ACを累積値で時系列に表示します。
子孫プロジェクトがある場合、子孫プロジェクトのバージョンも表示します。

## 未完了チケットの表示
基準日を元に未完了であるチケットを表示します。

## ベースライン
このプラグインでは、プロジェクトのある時点でのPVを記憶する機能となっています。
ベースラインを設定しておくことで、プロジェクトのある時点を基準に、タスクが増加(チケットが増加)していくと、チャートに乖離していく様子が表示され、どれくらい乖離しているかが認識しやすくなります。つまり、予定作業を超えた作業が増えている状態が可視化されます。ベースラインが設定されている場合は、ベースラインをもとにPVが計算されますので、注意してください。ただし、オプションの設定で、ベースラインを利用しないでEVM値を計算することもできます。この場合はベースライン設定後に変更・登録されたチケットも含めてEVM値が計算されます。（プロジェクトの実情に合わせて計算されることになります）

## 動作環境
Redmine 3.3.0 以上

my Environment:
  Redmine version                3.3.0.stable
  Ruby version                   2.1.8-p440 (2015-12-16) [i386-mingw32]
  Rails version                  4.2.6
  Environment                    production
  Database adapter               Mysql2

## 導入
1. ZIPファイルをダウンロードします
2. [redmine_root]/plugins/へ移動して、redmine_issue_evmフォルダを作成してください
3. 2.で作成したフォルダにZIPファイルを解凍します
4. 次のコマンドを入力して、マイグレーションしてください。rake redmine:plugins:migrate NAME=redmine_issue_evm RAILS_ENV=production
5. Redmineを再起動します

# 画面サンプル
#### 全体
![evm sample screenshot](./images/screenshot01.png "overview")

#### ベースラインの作成
![evm sample screenshot](./images/screenshot03.png "create new baseline")

#### ベースラインの履歴
![evm sample screenshot](./images/screenshot02.png "History of baseline")

#### プラグイン全体の設定
![evm sample screenshot](./images/screenshot04.png "plugin　setting")
