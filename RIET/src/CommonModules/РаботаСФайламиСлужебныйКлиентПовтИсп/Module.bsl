////////////////////////////////////////////////////////////////////////////////
// Подсистема "Работа с файлами".
//
////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

// Возвращает форму, которая используется при создании нового файла
// для выбора варианта создания.
Функция ФормаВыбораВариантаСозданияНовогоФайла() Экспорт
	
	ДоступнаКомандаСканировать = ФайловыеФункцииСлужебныйКлиент.ДоступнаКомандаСканировать();
	ПараметрыФормы = Новый Структура("ДоступнаКомандаСканировать", ДоступнаКомандаСканировать);
	Возврат ПолучитьФорму("Справочник.Файлы.Форма.ФормаНового", ПараметрыФормы);
	
КонецФункции

// Возвращает форму, которая используется для информирования 
// пользователей об особенностях возврата файлов в веб-клиенте.
Функция ФормаНапоминанияПередПоместитьФайл() Экспорт
	Возврат ПолучитьФорму("Справочник.Файлы.Форма.ФормаНапоминанияПередПоместитьФайл");
КонецФункции

// Возвращает форму, которая используется при возврате отредактированного 
// файла на сервер.
Функция ФормаВозвратаФайла() Экспорт
	Возврат ПолучитьФорму("Справочник.Файлы.Форма.ФормаВозвратаФайла");
КонецФункции

// Возвращает форму, которая используется для ввода 
// режима сохранения при экспорте папки, если на диске уже есть файл с таким именем.
Функция ФормаЭкспортаПапкиФайлСуществует() Экспорт
	Возврат ПолучитьФорму("Справочник.Файлы.Форма.ФайлСуществует");
КонецФункции

#КонецОбласти
