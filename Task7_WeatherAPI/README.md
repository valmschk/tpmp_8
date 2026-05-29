# Задание 1.7. iOS приложение прогноза погоды (URLSession + API)

**Вариант 25**  
**Выполнила:** Мещенко Валерия Вячеславовна, 2 курс 10 группа

## Цель работы
Изучить сетевое взаимодействие в iOS: отправка запросов к API, получение и парсинг JSON-данных.

## Технологии

| Технология | Назначение |
|------------|------------|
| URLSession | Отправка HTTP-запросов к API погоды |
| JSONSerialization | Парсинг JSON-ответа |
| CoreLocation | Определение текущего местоположения |
| OpenWeatherMap API | Источник данных о погоде |

## Реализованный функционал

-  Поиск погоды по названию города
-  Определение погоды по текущему местоположению (GPS)
-  Отображение температуры, влажности, описания погоды
-  Обработка ошибок (нет интернета, город не найден)
-  Скрытие клавиатуры по нажатию Enter
-  Запрос разрешения на геолокацию

## API

**Сервис:** OpenWeatherMap  
**URL:** `https://api.openweathermap.org/data/2.5/weather`  
**Параметры:**
- `q` – название города
- `appid` – API ключ
- `units=metric` – температура в Цельсиях
- `lang=ru` – описание на русском

## Скриншоты

| Этап | Изображение |
|------|-------------|
| Интерфейс приложения | ![ui](screenshot_ui.png) |
| Поиск погоды | ![search](screenshot_search.png) |
| Результат | ![result](screenshot_result.png) |
| Запрос геолокации | ![location](screenshot_location.png) |
| Ошибка при отсутствии интернета | ![error](screenshot_error.png) |

## Ключевой код

### Отправка запроса к API
```swift
let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric&lang=ru"
guard let url = URL(string: urlString) else { return }

URLSession.shared.dataTask(with: url) { data, response, error in
    guard let data = data, error == nil else { return }
    // Парсинг JSON
}.resume()
