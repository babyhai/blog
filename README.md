Blog
=======

### 系统依赖

* Ruby ( = 2.3.1 )
* mysql ( >= 5.7 )
* Nginx ( >= 1.4 )


1. 克隆

  `git clone  https://github.com/babyhai/blog`

  `cd blog`

2. 安装依赖项和配置

  ```shell
  gem install bundler

  bundle install

  cp config/application.yml.example config/application.yml

  cp config/database.yml.example config/database.yml
  ```

  根据需要更新 application.yml 和 database.yml 的内容

3. 开始吧！

  ```shell
  rails s
  ```

  打开浏览器 http://localhost:3000

  如果发现任何错误，请检查您的数据库的用户和密码。

4. 发布第一个博客

访问：http：// localhost：3000 / admin，输入您的用户名和密码application.yml。然后，发布一篇新文章。

OK，就是这样。
