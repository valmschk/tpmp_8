# Задание 2.1. Приложение «Брестская крепость» (Путеводитель)

**Вариант 25**  
**Выполнила:** Мещенко Валерия Вячеславовна, 2 курс 10 группа

## Функционал

- ✅ Авторизация через Login / Sign Up
- ✅ Сохранение сессии через `UserDefaults`
- ✅ Список памятников в `UICollectionView`
- ✅ Данные о памятниках из `.plist` файла
- ✅ Переход на экран с детальной информацией
- ✅ Изображения из `Assets.xcassets`

## Архитектура MVC

| Компонент | Файл | Назначение |
|-----------|------|------------|
| Model | `MonumentInfo.plist` | Хранение данных о памятниках |
| View | `Main.storyboard` | Интерфейс (авторизация, коллекция, детали) |
| Controller | `ViewController.swift`, `SecondViewController.swift`, `ThirdViewController.swift` | Логика |

## Ключевой код

### Сохранение сессии
```swift
UserDefaults.standard.set(loginReg.text!, forKey: "login")
