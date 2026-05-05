# learn-log01

このドキュメントはふりかえりで疑問点や使用技術の理解、解説を記載します。

## 理解・疑問の整理

前提：RubyやRailsの初心者がRailsアプリを個人開発で作成し、開発後に使っている技術の理解を深めようとしています。

- 言語（Ruby）について
    - Rubyの特徴
    - Rubyの得意なこと
    - Rubyで不得意なこと
    - Rubyの基本的な言語機能と文法
    - Rubyに特有の言語機能や文法
- フレームワーク（Rails）について
    - Railsの特徴
    - Railsの得意なこと
    - Railsの不得意なこと
    - Railsの基本的な使いかたや機能
    - Railsに特有な記法（あれば）
    - Railsのアーキテクチャ（MVCなど）
    - Railsのフォルダ構成やファイルの種類、役割、アーキテクチャとの関係
    - Railsでのデータベースの扱い方
- データベース（PostgreSQL）について
    - PostgreSQLの特徴
    - PostgreSQLの得意なこと、不得意なこと
    - PostgreSQLの基本的な機能や使い方、コマンド
- このプロジェクトのコード解説
    - このプロジェクトで作成したコードについて、コードブロックを示しながら、RubyやHTML, CSSのコードを解説
    - アーキテクチャとの関連
    - Rubyの文法的な説明

---

## Rubyについて

### Rubyの特徴

ここでは「Rubyとは何者か」を、後の文法・Rails の話につながるように具体的に整理する。細かい構文はステップ2以降で扱う。

#### インタプリタ型で動的型付け

Ruby のソースは、実行時にインタプリタ（現行の MRI/CRuby では YARV という仮想マシン）が読み取り、逐次実行する。コンパイルしてから配布するスタイル（Go や Rust のバイナリのように）ではない。

変数やメソッドの引数には、あらかじめ「この変数は整数」といった型宣言を書かない。代入やメソッド呼び出しのたびに、オブジェクトが持つクラスに応じた振る舞いが決まる（ダックタイピング：「アヒルのように歩けばアヒル」）。そのため、エディタだけでは拾いにくいミスが実行時まで残りやすい一方、プロトタイプや DSL（ドメイン特化言語）のような柔らかい API を書きやすい。

#### 純粋なオブジェクト指向

Ruby では、数値や `nil` を含め、ほぼすべてがオブジェクトである。`1` もオブジェクトなので `1.odd?` のようにメソッドを呼べる。クラス自体もオブジェクトであり、`Class` のインスタンスとして扱える。メソッド呼び出しが中心で、「データとそれに紐づく操作」がオブジェクトにまとまる設計と相性がよい。

#### ブロック・イテレータ・クロージャ

メソッドに「名前のないコード片（ブロック）」を渡せる。`array.each { |x| ... }` の `{ |x| ... }` が典型で、コレクションの走査だけでなく、ファイルを開いて閉じるまでを `File.open(...) { |f| ... }` のように囲む、といった「前後処理のパターン」に広く使われる。ブロックは外側の変数を捕捉するクロージャにもなる。Rails のルーティングや Active Record のスコープ定義でも、この「ブロックで設定を渡す」スタイルが頻出する。

#### 柔軟な構文と「読みやすさ」を優先した設計

省略可能な括弧、`do`/`end` と `{`/`}` の使い分け、`?`/`!` をメソッド名に付けて述語や危険な操作を区別する慣習など、英語に近い読み味を目指した文法が多い。作成者の松本行弘氏が重んじる「プログラマを楽にする（MINASWAN: Matz is nice and so we are nice）」はコミュニティの空気としても知られ、言語設計のトレードオフでは「一貫性よりも実用と読みやすさ」を選ぶ場面がある、と捉えてよい。

#### メタプログラミングとオープンクラス

実行中にクラスやモジュールにメソッドを追加・再定義できる。`define_method` や `method_missing`、モジュールの `included`/`prepended` フックなどを使うと、繰り返しボイラープレートを減らす API をライブラリ側で生成できる。Rails の `has_many` や `validates` のような宣言的マクロは、この仕組みの上に乗っている。強力な反面、「どこでこのメソッドが定義されたか」が追いにくくなるので、フレームワークに任せる範囲と自前で触る範囲の線引きが重要になる。

#### ガベージコレクション

オブジェクトの寿命はランタイムが推定し、不要になったメモリを回収する。手動 `free` は不要だが、メモリ使用量や一時オブジェクトの大量生成には注意が必要（大規模データ処理では別言語やストリーミング設計と比較検討することがある）。

#### 実装とエコシステム

実務でよく使われるのは MRI（公式の C 実装）。JRuby（JVM 上）、TruffleRuby など別実装もある。ライブラリは RubyGems と `bundler` で依存を宣言し、バージョンを揃える。Rails はその代表例で、「Web アプリ一式」を Gem として引き寄せる世界観になっている。

#### このプロジェクトとの対応関係（先取りの地図）

このリポジトリでは、Ruby は主に次の場所で効いてくる。

- モデル・コントローラ・ヘルパなどの `.rb` ファイルでのロジックと HTTP 応答の組み立て
- ERB テンプレートの `<% %>` / `<%= %>` の中に埋め込まれる Ruby 式
- RSpec の `expect { ... }.to change(...)` のような、ブロックを受け取るマッチャ

「特徴」を押さえたうえで、以下では用途面から見た適性を整理する。そのあと「基本文法」などに進むと、Rails の記法が単なる暗記ではなく、言語の延長として読めるようになる。

### Rubyの得意なこと

「得意」とは、設計思想・エコシステム・慣習が噛み合い、少ない記述で安全に進めやすい領域を指す。万能ではないが、次のような場面で強みが出やすい。

#### リクエスト処理型の Web アプリと Rails

HTTP リクエストを受け、認可・バリデーション・DB 更新・HTML/JSON 応答までを一気通貫で組むスタイルは、Ruby と Rails の主戦場である。ルーティング、ORM、テンプレート、セキュリティ対策のデフォルトが揃っており、個人開発から中規模の業務システムまで、変更を繰り返しながら機能を積み上げやすい。このリポジトリのブログも、その典型例になる。

#### プロトタイプと仕様の早期検証

動的型付けと柔らかいオブジェクトモデルのおかげで、スキーマや API がまだ固まっていない段階でも試行錯誤が速い。後からモデルを分割したり、バリデーションを足したりする道筋も、Rails の規約に沿っていれば迷いにくい。

#### 読みやすさとチーム開発のしやすさ

メソッド名やブロック構文が「文章に近い」形になりやすく、ドメイン語彙をメソッド名に載せた設計（例：`article.editable_by?(user)`）と相性がよい。設定より規約（Convention over Configuration）により、プロジェクト間でフォルダの意味が揃いやすく、オンボーディングコストを下げやすい。

#### 内部ツール・運用スクリプト・タスク自動化

Rake タスクや、短いスクリプトで CSV を読み、API を叩き、メールを送る、といった「バッチ寄りの仕事」も Ruby は得意とされる。ファイルや文字列、時刻の扱いが標準ライブラリと Gem で揃っており、ワンオフでも壊れにくい形に整えやすい。

#### メタプログラミングを活かしたライブラリ・DSL

宣言的な API（Rails の関連定義やバリデーション、ルーティングの `scope` ブロックなど）を、利用者側は短く書ける。フレームワーク作者・Gem 作者にとって表現力が高く、アプリケーション作者にとっては「設定ファイルが Ruby になる」ことで条件分岐や再利用を書ける利点がある。

#### コミュニティと Gem

「やりたいこと」が先にあり、それを Gem で足す文化が根強い。認証（Devise）、テスト（RSpec）、デプロイ補助（このプロジェクトの Kamal など）まで、周辺が揃っていると判断しやすい。

### Rubyで不得意なこと（向きにくい用途）

「不得意」は、言語が最適化してきた軸とズレるとコストが跳ね上がる、という意味で使う。代替や併用技術がある前提で、期待値を合わせておくとよい。

#### ミリ秒単位を争う超低レイテンシ処理

インタプリタの起動・実行モデル、GC の存在により、常時サブミリ秒を切る処理や、カーネルに近いリアルタイム制御の主役には向きにくい。ゲームエンジン、高頻度取引のコア、組み込みファームウェアの第一言語は、通常 C/C++/Rust など別言語になる。

#### CPU をフルに食う数値計算・大規模シミュレーション

素の Ruby は数値ループの最適化が、LLVM ネイティブや SIMD 前提の言語に比べ不利になりやすい。データサイエンスや重い行列演算では、Python から C/Fortran 拡張を呼ぶ構成や、Julia など別言語が主役になることが多い。Ruby 側はオーケストレーションに回す、という住み分けが現実的である。

#### メモリとプロセス数が極端にシビアな環境

長時間稼働するワーカーを大量に立て、1 プロセスあたりの RAM を厳密に抑えなければならない場合、ランタイムとオブジェクトのオーバーヘッドがボトルネックになりうる。対策（チューニング、プロセスモデルの見直し、一部を別言語のマイクロサービスに分離）はあるが、最初から「極小メモリ・極多プロセス」を最優先するなら他言語と比較検討する価値がある。

#### コンパイル時に型を完全に固定したい超大規模モノレポ

動的型付けのままでは、リファクタリング時に実行時まで気づけない不整合が起きうる。Sorbet や RBS による静的型チェック、厳格なレビュー・テストで埋め合わせる道はあるが、「型宣言なしの巨大コードベースを機械的に保証したい」という要件だけを見ると、最初から静的型がデフォルトの言語のほうが負担が小さい場面もある。

#### 単一の小さなネイティブバイナリ配布

依存をすべて静的リンクした 1 ファイルの CLI を配布したい、といった文脈では Go などが選ばれやすい。Ruby もパッケージング手段（Traveling Ruby、mruby、コンテナイメージなど）はあるが、「デフォルトの得意分野」というより運用設計が必要になる。

#### モバイルクライアントの第一言語

iOS/Android の公式スタックは Swift/Kotlin などが中心で、Ruby はサーバーやスクリプト側に置かれることがほとんどである。

---

以上はあくまで適性の整理である。Ruby 3 系の性能改善や JIT の進展により、「向かない」と一刀切りできない領域も増えている。自分のプロジェクトが上の「得意」に近いかどうかを見極め、ボトルネックが「不得意」側に寄ったら別言語・別サービスに切り出す、という設計が現実的である。

### Rubyの基本的な言語機能と文法

ここでは Rails のコードを読むうえで最低限押さえておきたい要素を、短い実行イメージ付きで並べる。細部の例外やエッジケースは公式ドキュメントや書籍で補う想定である。

#### リテラルと真偽・nil

数値は整数と浮動小数の区別がある。`0b` / `0o` / `0x` は二進・八進・十六進。文字列はシングルクォート（展開なし）とダブルクォート（`#{}` で式展開）がある。

```ruby
1 + 2          # => 3
1.5 * 2        # => 3.0
"hello"        # 文字列
'no #{interp}' # そのまま

name = "Ada"
greeting = "Hello, #{name}"  # => "Hello, Ada"

true && false  # => false
nil            # 「値がない」オブジェクト。false ではないが条件では偽として扱われる
```

`if` の条件では、`false` と `nil` だけが偽。`0` や空文字列 `""` は真である（他言語と違うので注意）。

#### シンボル

`:title` のようにコロンで始まる識別子。イミュータブルで、同じ内容なら同一オブジェクトとして扱われやすい。ハッシュのキーや、Rails でメソッド名・カラム名を渡すときに頻出する。

```ruby
:draft == :draft   # => true
{ status: :published }   # キーはシンボル :status（新しいハッシュリテラル記法）
# { :status => :published } のシンタックスシュガー
```

#### 配列とハッシュ

順序付きコレクションとキー・値のマップ。末尾カンマを許すスタイルがよく使われる。

```ruby
titles = ["First", "Second"]
titles << "Third"           # 末尾に追加
titles[0]                   # => "First"

counts = { draft: 1, published: 5 }
counts[:draft]              # => 1
counts.fetch(:missing) { 0 }  # キーがなければブロックの結果（fetch は KeyError を避けたいときに便利）
```

#### 変数の種類（スコープの違い）

ローカル変数は英小文字またはアンダースコア。インスタンス変数は `@title` のようにオブジェクトごとに保持（Active Record の `article.title` の裏で `@attributes` などに繋がるイメージ）。クラス変数は `@@count`（継承で共有される点に注意）。定数は `Article` のように大文字で始まる名前（再代入は警告付きで可能な場合がある）。

```ruby
class Counter
  @@total = 0

  def initialize
    @value = 0
  end

  def bump
    @value += 1
    @@total += 1
  end
end
```

グローバル変数 `$stdout` などは標準ライブラリで見かけるが、アプリケーションコードではほぼ使わない。

#### メソッド定義、引数、戻り値

`def` で定義する。最後に評価された式が戻り値になる（`return` は早期脱出に使う）。引数にはデフォルト値、キーワード引数、可変長引数（`*rest`）を組み合わせられる。

```ruby
def greet(name, punctuation: "!")  # pubctuationはキーワード引数で、デフォルト値が"!"
  "Hello, #{name}#{punctuation}"
end

greet("Bob")                      # => "Hello, Bob!"
greet("Bob", punctuation: "?")    # => "Hello, Bob?"

def line(items)
  items.join(", ")
end

line(["a", "b"])  # => "a, b"
```

メソッド呼び出しの括弧は多くの場面で省略できる。`puts "hi"` と `puts("hi")` は同じ。

```ruby
user.email.upcase  # レシーバ user に対し email を呼び、さらに upcase
```

#### 述語メソッドと危険メソッドの慣習

末尾が `?` のメソッドは真偽を返すことが多い（例：`empty?`）。末尾が `!` のメソッドは「破壊的」に自分自身を変える版であることが多い（例：`sort!`）。Rails では `save` と `save!` のように、失敗時に例外を投げるかどうかの違いに使われる。

```ruby
s = "  hi  "
s.strip   # 新しい文字列 "hi" を返す
s.strip!  # s 自身を変更し、変更がなければ nil
# 定義側で意味に応じて?や!をつける「慣習」になっている。言語側で保障するわけではない。
```

#### 制御構造：if / unless / case

```ruby
if user.nil?    # nil? はBasicObjectに定義されている「自分はnilか」と聞く述語メソッド
  "guest"
elsif user.admin?
  "admin"
else
  "member"
end

# 修飾子形式（1 行に収まるとき）
return if message.nil? || message.empty?

case status
when :draft
  "下書き"
when :published
  "公開"
else
  "不明"
end
```

`unless` は「if not」だが、複雑な条件をねじ込むと読みにくくなるので、シンプルな否定に留めるのが無難である。

#### 繰り返しとイテレータ

インデックスの `for` はほぼ使われず、`each` などのイテレータが標準である。整数には `times` や `upto` がある。範囲オブジェクト `(1..3)` は両端含み、`(1...3)` は終端を含まない。

```ruby
[10, 20, 30].each do |n|    # eachは配列などがもつインスタンスメソッド。Arrayにはeachが定義されいている。内部では要素を順にyieldする実装になっている。|i|はブロックパラメータと呼ばれ、eachが要素を返すたびにその値が入る。
  puts n * 2
end

3.times { |i| puts i }    # Integer#timesはブロックに0,1,2を渡す

(1..3).each { |i| puts i }
```

#### ブロック、`yield`、メソッドオブジェクト（概要）

メソッドの末尾に `do ... end` または `{ ... }` を渡すとブロックになる。定義側は `yield` でブロックを実行する。

```ruby
def with_timing
  t0 = Time.now
  yield
  Time.now - t0
end

with_timing { sleep 0.1 }  # おおよそ 0.1 秒
```

ブロックをオブジェクトとして保持したいときは `lambda` や `proc` を使う（引数の扱いや `return` の挙動が異なる。まずは「ブロックがほとんど」でよい）。

#### クラス、モジュール、`initialize`

`initialize` は `new` から呼ばれるコンストラクタに相当する。`attr_reader` / `attr_writer` / `attr_accessor` でゲッター・セッターを短く定義できる。

```ruby
module Timestamped
  def touch
    @updated_at = Time.now
  end
end
# モジュールはクラスに似ているが、newして使うものではない、継承の親にはしない、代わりにinclude / prepend / extendで機能をミックスインするのに使う。

class Post
  include Timestamped

  attr_accessor :title

  def initialize(title)
    @title = title
    touch
  end
end

p = Post.new("Hello")
p.title # => "Hello"
```

`include` はインスタンスメソッドとしてミックスインする。クラスメソッド側に足すときは `extend` を使う。

#### `self` とクラスメソッド

メソッド定義の文脈によって `self` が指すオブジェクトが変わる。クラス定義の直下で `def self.foo` と書くとクラスメソッドになる。

```ruby
class Article
  def self.from_params(params)
    new(title: params[:title])
  end

  def summary
    "#{self.class.name}: #{@title}"  # インスタンス内では self はこのインスタンス
  end
end
# Article.new.summary のように、インスタンスメソッドはインスタンスに対して呼ぶ Article#summary とドキュメントでは書く
# Article.from_params(params) のように、クラスメソッドはクラスに対して呼ぶ Article.from_params とドキュメントでは書く
```

#### 例外処理

失敗しうる処理を `begin`～`rescue` で囲み、型に応じて分岐する。`ensure` は成功・失敗に関わらず実行される。

```ruby
begin
  File.read("missing.txt")
rescue Errno::ENOENT    # ::は名前空間の区切り
  "(no file)"
end
```

Rails のコントローラやモデルでは、フレームワークが用意したフックや `save!` の例外に任せる場面が多く、あらゆる箇所で `begin`/`rescue` する必要はない。

#### よく見るイディオム

```ruby
# 左側が nil または false なら右側を使う
name = nickname || "anonymous"

# 変数が nil または false のときだけ代入（メモ化の素朴な形）
@cache ||= expensive_computation()

# 安全呼び出し（receiver が nil なら nil を返し、NoMethodError にしない）
user&.profile&.display_name    # userがnilでなければprofileを呼び、nilならprofileを呼ばずに式全体の値はnil

# ハッシュをキーワード引数のように展開（Rails の params 周りで見かける）
opts = { punctuation: "?" }
greet("Bob", **opts)
```

#### このプロジェクトでつながる読み方

- コントローラの `params.require(:article).permit(:title, :body)` は、ハッシュ操作とシンボルキーの典型例である。
- モデルの `validates :title, presence: true` は、クラスマクロにシンボルとオプションハッシュを渡している。
- ビューの `<%= @article.title %>` は、インスタンス変数のゲッター（Active Record が提供）を ERb が出力している。

### Rubyに特有の言語機能や文法

基本文法の外側で、他言語から来ると「Ruby っぽい」と感じる要素をまとめる。Rails はこれらをフレームワーク内部で多用するため、名前だけ知っておくとドキュメントやスタックトレースが読みやすくなる。

#### クラスの再オープン（モンキーパッチ）

同じクラス名の `class` ブロックを後から再度書ける。定義がマージされ、メソッドを追加・上書きできる。ライブラリが「既存クラスに便利メソッドを足す」ときに使われる。強力だが、名前の衝突や挙動変更に注意する。

```ruby
class String
  def shout
    upcase + "!"
  end
end

"hi".shout  # => "HI!"
```

#### メソッド探索と `include` / `prepend` / `extend`

`include M` は通常、インスタンスメソッドとしてミックスインする。`prepend M` は継承チェーンの手前に差し込むため、`super` の向き先が変わり、モジュール側で既存メソッドをラップできる。`extend M` はそのオブジェクト（多くはクラス）の特異クラスにメソッドを足し、クラスメソッドとして使う。

```ruby
module Auditable
  def save(*args, &block)
    puts "saving..."
    super
  end
end

class Article
  prepend Auditable
end
```

Rails の Concern や Active Support の一部は、この仕組みの上に乗っている。

##### 補足

prepend：同じインスタンスメソッドだが、「先に」モジュールを見る
prepend もインスタンスメソッドを足しますが、探索順でモジュールがクラスより前に入ります。

```ruby
module Audit
  def save
    puts "before"
    super   # 次は「本来の C#save」へ
  end
end

class C
  prepend Audit
  def save
    puts "core"
  end
end

C.new.save
# before
# core
```

C にも save があり、Audit にも save があるとき、include だとクラス側が先に勝つことが多い一方、prepend だと モジュールの save が先に呼ばれ、super でクラス本体の save に渡せます。Rails の Concern で「コールバックをラップする」イメージに近いです。

短く言うと、prepend は「インスタンスメソッドを足す」点は include と同じだが、メソッドを探す順番でモジュールをクラスの手前に差すのが違いです。

extend：レシーバ「そのオブジェクト」にだけメソッドを足す
extend M は、渡したオブジェクトの特異クラスにモジュールのインスタンスメソッドを足します。だから：

クラスに対して extend → クラスメソッドになる（self がクラスなので）。
あるインスタンスにだけ extend → そのインスタンスだけがそのメソッドを持つ。

```ruby
module Plugin
  def foo = 42
end

class Foo
  extend Plugin
end

Foo.foo      # => 42（クラスに対して呼ぶ）

obj = "hi"
obj.extend(Plugin)
obj.foo      # => 42（この文字列オブジェクトだけ）

"other".foo  # NoMethodError
```

include が「このクラスの全インスタンスに共通のメソッド」なのに対し、extend は「今指定したオブジェクト（多くはクラス）にだけメソッドを生やす」感じです。

#### splat：`*` と `**`

一つのメソッドに「可変個の位置引数」や「ハッシュ／キーワードをまとめて受け渡し」するときに使う。定義側の `*names` は残りを配列に、`**opts` はキーワード引数をハッシュにまとめる（Ruby 3 系ではキーワードと位置の区別が厳密になっている点に注意）。

```ruby
def combine(first, *rest, **kw)
  [first, rest, kw]
end

combine(1, 2, 3, x: 10)  # => [1, [2, 3], {:x=>10}]
```

#### ブロックを `Proc` として受け取る `&`

メソッドの最後の仮引数が `&block` のとき、渡されたブロックが `Proc` 化される。逆に呼び出しで `&callable` と書くと、`Proc` や `method(:foo)` をブロックとして渡せる。

```ruby
def twice(&block)
  block.call
  block.call
end

twice { puts "hi" }

doubler = proc { |x| x * 2 }    # 組み込みのオブジェクトProcのインスタンスを作成
[1, 2, 3].map(&doubler)  # => [2, 4, 6]    # Procがもつブロック（処理）を渡す
```

#### `define_method` と `class_eval` / `module_eval`

実行時にメソッド名と本体を決められる。DSL や `attr_accessor` のようなマクロの実装の根幹。

```ruby
class Robot
  %i[walk jump].each do |action|    # %iは中身をシンボルにする。[:walk, :jump]と同じ。
    define_method(action) { "#{action}ing" }
  end
end

Robot.new.walk  # => "walking"
```

`class_eval` に文字列を渡す形はメタプログラミングで古くからあるが、セキュリティとデバッグの観点ではブロック形式が推奨されやすい。

#### `method_missing` と `respond_to_missing?`

存在しないメソッドが呼ばれたときにフックできる。Active Record の動的属性（`find_by_email` のような動的スコープ）のような API に使われてきた。現代ではメソッド定義のコストが下がったため、安易に使わず、`respond_to?` と整合させるなら `respond_to_missing?` も実装するのが作法として知られる。

```ruby
class Ghost
  def method_missing(name, *)
    "called #{name}"
  end
end

Ghost.new.foo  # => "called foo"
```

#### 記号付きリテラルとヒアドキュメント

`%w[a b c]` はスペース区切りで文字列配列、`%i[a b c]` はシンボル配列。`%q{}` はシングルクォート相当、`%r{pat}` は正規表現。ヒアドキュメントは複数行文字列。`<<~EOS` は先頭のインデントをそろえて取り除く（チルダ付き）。

```ruby
sql = <<~SQL
  SELECT *
  FROM articles
  WHERE published = TRUE
SQL
```

##### 補足

`<<~`タグ で「ここからヒアドキュメント（複数行の文字列）が始まる」と宣言する。
同じ タグ だけの行で終わりを示す（先頭にスペースを付けないのが基本）。

```ruby
query = <<~HOGEHOGE
  SELECT *
  FROM articles
HOGEHOGE
```

終端の HOGEHOGE は、開始時に書いた名前と完全一致させる必要があります。

`~`（チルダ）の意味: 
`<<~` は終端行に合わせて、各行の先頭の余分なインデントをそろえて削るための書き方です。コードをインデントしながら書いても、文字列としては左端が揃ったきれいな形にできます。

`<<-` や `<<`（チルダなし）だとインデントの扱いが違うので、ドキュメントや Rails でよく見るのは `<<~EOS` や `<<~SQL` のような形です。EOS は "end of string" の略の慣習です。

#### `Struct` と軽いデータ載せ

キーワード引数付き `Struct` で、小さな値オブジェクトや戻り値の束ねを手早く定義できる。Active Record の代替ではないが、スクリプトやテストで見かける。

```ruby
Point = Struct.new(:x, :y, keyword_init: true)    # Point型を定義して返す。クラスを生成するファクトリだと思うと整理しやすい。
Point.new(x: 1, y: 2)
```

#### Refinements（`refine` / `using`）

ファイルやブロック単位でだけ有効なモンキーパッチ。グローバルにクラスを汚染しないが、有効範囲が分かりにくくなることもある。標準ライブラリや一部 Gem で使われる。アプリ本体ではあまり目にしないことが多い。

##### 補足

refine SomeClass do ... end … 「このモジュールの中でだけ、SomeClass にこういうメソッドを足す」と定義する。
using ThatModule … 「このレキシカルスコープ（ファイルやブロックの範囲）では、その refine を有効にする」。

```ruby
module Shout
  refine String do
    def shout
      upcase + "!"
    end
  end
end

using Shout

puts "hello".shout   # => HELLO!
```

同じファイルの using Shout より下では "hello".shout が使えます。

#### 特異メソッドと `class << self`

特定の一つのオブジェクトだけに付けるメソッドを特異メソッド（シングルトンメソッド）という。`class << obj` はそのオブジェクトの特異クラスを開く構文。クラスメソッドをまとめて書くときに `class << self` が使われる。

```ruby
obj = "hello"
def obj.shout
  upcase + "!"
end

class Foo
  class << self
    def bar
      1
    end
  end
end
```

#### `||` と `or` の優先順位の落とし穴

`||` のほうが結合が強い。`or` は優先順位が低く、制御フローの「左が真なら右を評価しない」用途で使われることもあるが、代入と組み合わせると直感と違う解釈になることがある。迷ったら `||` と括弧で書くほうが安全なことが多い。

```ruby
# 意図：name がなければ代入
# name = nil or "guest"  # これは (name = nil) or "guest" になりやすい（意図と違う）
name = nil || "guest"    # => "guest"
```

#### まとめ：Rails との関係

- ルーティング、コールバック、`validates` などは「クラス定義時にブロックとシンボルを渡し、内部で `define_method` やフックでつなぐ」パターンが多い。
- `params` の展開、スコープの `-> { where(...) }`、RSpec の `expect { }.to change` は、ブロックと `&`、lambda の文化に乗っている。
- 再オープンと Active Support の `String` / `Hash` 拡張は、プロジェクトで `blank?` などが「標準のように」見える理由のひとつである。

ここまでで Ruby の輪郭は揃う。続くドキュメントでは Rails・PostgreSQL・このリポジトリのコードにフォーカスを移すとよい。
