# dev-log01

この文書は最初の開発プランの作業記録、補足、メモや備忘録です。開発者やAIが作業やコンテキストを見返せるようにします。

## ここまでの状況（初期設定）
- Railsブログアプリのリポジトリ初期設定が一通り完了した状態。
- 機能実装（認証/記事/公開/コメント）はこれから着手する。

## ハマったポイント / 備忘録

### Devkit / ridk / MSYS2（Windows）
- 事象: Devkit/ridk 周辺でセットアップが失敗。
- 原因: MSYS2 のリポジトリ ミラー と パッケージDBの不整合 により、取得先のファイルが 404 となっていた。
- 学び: 404 が出るときは「ネットワーク」だけでなく、ミラー先・パッケージDB整合を疑う。

### PostgreSQL: DB設定前に psql でユーザー作成が必要
- 事象: DB設定の途中で、まず `psql` でユーザーを作成する必要があった。
- 学び: `rails db:create` などの前に、ローカル環境側のユーザー/権限/認証方式の前提が揃っている必要がある。

### DB認証情報: .env を導入して参照、.env はリポジトリに含めない
- 方針: DB認証情報は `.env` を導入してそこから参照する。
- 運用:
  - `.env` は git管理しない（リポジトリに含めない）
  - 必要なら `.env.example` のような秘匿なしテンプレを置く

## RSpec: 最初のスモークテスト追加（Rails起動 / DB接続）
- 目的: 機能実装が無い段階でも「プロジェクト/ライブラリ/DB設定が成立している」ことを自動で確かめられるようにする。
- 前提: `rails db:prepare` を test環境 に対して実行済み。
- 追加したspec:
  - `spec/smoke/boot_spec.rb`（Railsがbootできること）
  - `spec/smoke/database_spec.rb`（DB接続が確立でき、`SELECT 1` が通ること）
- 実行コマンド: `bundle exec rspec`
- 結果: `3 examples, 0 failures`
  - 補足: `VIPS-WARNING` が出たが、テストは成功（image_processing/libvips の追加モジュール不足に関する警告と思われる）

## MVP機能実装（ユーザー認証・記事・コメント）

### ユーザー認証（Devise）
- `User` モデル、サインアップ/サインイン/ログアウトのルートと画面
- レイアウトに最小ナビ（Sign up / Sign in、ログイン時は Log out は `DELETE` で送信）
- トップは `PagesController#home`、`root` を設定
- `flash`（`notice` / `alert`）をレイアウトで表示

### 記事（Article）
- モデル: `title`、`body`、`user_id`。`User` は `has_many :articles`
- 一覧・詳細は未ログインでも閲覧可。新規・編集・削除はログイン必須。編集・削除は記事の作者のみ
- Strong Parameters は `:title` / `:body` のみ。記事のユーザー紐づけは `current_user` 側で実施
- MVPの方針として公開フラグ・下書きは置かず、「投稿した記事はゲスト含め一覧・詳細で見られる」

### コメント（Comment）
- モデル: `body`、`article_id`、`user_id`。`Article` / `User` はそれぞれ `has_many :comments`
- ルートは `articles` にネストした `comments`（`create` / `destroy` のみ）
- コメントの作成・削除はログイン必須。削除はコメント投稿者または記事の作者
- 記事詳細にコメント一覧・投稿フォーム・削除ボタン（権限がある場合）

### テスト（RSpec、最小）
- スモーク、`User` / `Article` / `Comment` のモデル、`Devise` サインイン画面、`Articles` / `Comments` のリクエストspec（未ログイン拒否、作成・削除の権限など）
- request spec 用に `rails_helper` で `Devise::Test::IntegrationHelpers` を読み込み

### 動作確認
- ブラウザで記事の CRUD とコメントの投稿・削除まで確認済み

## デザインシステム実装（MVP）

方針は `dev-plan01.md` の「デザインシステム方針」「デザインシステム実装手順」に沿う。ウォームライト背景・アンバー系アクセント・ガラス調パネルを CSS 変数と共通クラスで統一した。

- トークンとスタイル: `app/assets/stylesheets/application.css` に `:root` の色・余白・角丸・影・ガラス用変数を置き、`body`・リンク・`:focus-visible`・フラッシュ・ナビ・ボタン・フォーム・カード／パネルなどをトークン参照で定義。
- レイアウト: `app/views/layouts/application.html.erb` でシェル（最大幅・横余白）、 sticky ナビ、`content_for :title` とページ見出しの流れを整理。
- 適用した画面: トップ（`pages/home`）、記事一覧・詳細・フォーム（`articles/*`）、記事詳細のコメント欄、Devise 一式。
- Devise: `rails generate devise:views` でビューをプロジェクト側に生成し、各テンプレートを `panel glass`、`page-title`、`field` / `form-actions`、`btn` などに合わせて調整。共有パーシャルはエラー表示・サインイン関連リンクをデザインシステムに合わせた（メーラー HTML は対象外）。
- 補助クラス例: `.field--check`（remember me 等）、`.field-hint`、`.devise-links`、`.form-actions` など。
- 動作確認: ブラウザでログインまわりを含め確認。テストは `bundle exec rspec` で問題なし。

この時点で MVP 範囲のデザインシステム適用は完了とした。狭い画面・ガラス上の可読性・ホバーとフォーカスの最終調整は必要に応じて別途。

