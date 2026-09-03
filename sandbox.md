% Preview automation


# entr + WEBrick + HTTP-request

В этом сценарии ваша автоматизация разделяется на два независимых процесса, которые выполняются параллельно:

- entr занимается только сборкой: он следит за манифестом и при изменениях вызывает ваше Ruby-приложение.
- Приложение обновляет index.html и перезаписывает крошечный файл version.txt.Локальный сервер занимается только отдачей файлов: он просто «смотрит» в папку с результатами сборки.

## version.txt

```ruby
# Сборка вашего HTML...
# File.write('dist/index.html', html_content)

# Создаем маркер изменения
File.write('dist/version.txt', Time.now.to_i.to_s)
````

## JS to html body

```js
<script>
  let currentVersion = null;
  setInterval(async () => {
    try {
      // Добавляем ?t=..., чтобы браузер не кэшировал запрос
      const res = await fetch(`version.txt?t=${Date.now()}`);
      if (!res.ok) return;
      const text = await res.text();
      
      if (currentVersion === null) {
        currentVersion = text;
      } else if (currentVersion !== text) {
        window.location.reload();
      }
    } catch (e) {
      // Игнорируем ошибки, если сервер временно занят перезаписью
    }
  }, 500); // 500 мс — задержка незаметна, а нагрузка нулевая
</script>
````

## 3

Bash automaton

    ruby -run -e httpd dist/ -p 8000 & ls manifest.txt | entr my_ruby_app manifest.txt
