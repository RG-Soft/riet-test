////////////////////////////////////////////////////////////////////////////////
// Подсистема "Присоединенные файлы".
//
////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Позволяет переопределить справочники хранения файлов по типам владельцев.
// 
// Параметры:
//  ТипВладелецФайла  - Тип - тип ссылки объекта, к которому добавляется файл.
//
//  ИменаСправочников - Соответствие - содержит в ключах имена справочников.
//                      При вызове содержит стандартное имя одного справочника,
//                      помеченного, как основной (если существует).
//                      Основной справочник используется для интерактивного
//                      взаимодействия с пользователем. Чтобы указать основной
//                      справочник, нужно установить Истина в значение соответствия.
//                      Если установить Истина более одного раза, тогда будет ошибка.
//
Процедура ПриОпределенииСправочниковХраненияФайлов(ТипВладелецФайла, ИменаСправочников) Экспорт
	
	ИменаСправочников.Вставить("ЭДПрисоединенныеФайлы");
	
КонецПроцедуры

// Формирует массив метаданных, которые не должны выводиться в настройках очистки файлов.
//
// Параметры:
//   МассивИсключений   - Массив - метаданные, которые не должны выводиться в настройках очистки файлов.
//
// Например:
//   МассивИсключений.Добавить(Метаданные.Справочники._ДемоНоменклатураПрисоединенныеФайлы);
//
Процедура ПриОпределенииОбъектовИсключенияОчисткиФайлов(МассивИсключений) Экспорт

КонецПроцедуры

// Формирует массив метаданных, которые не должны выводиться в настройках синхронизации файлов.
//
// Параметры:
//   МассивИсключений   -Массив - метаданные, которые не должны выводиться в настройках синхронизации файлов.
//
// Например:
//   МассивИсключений.Добавить(Метаданные.Справочники._ДемоНоменклатураПрисоединенныеФайлы);
//
Процедура ПриОпределенииОбъектовИсключенияСинхронизацииФайлов(МассивИсключений) Экспорт

КонецПроцедуры

// Устарела.Следует использовать ПриОпределенииОбъектовИсключенияОчисткиФайлов.
//
Функция ОбъектыИсключенияПриОчисткеФайлов() Экспорт
	
	Массив = Новый Массив;
	
	Возврат Массив;
	
КонецФункции

#КонецОбласти

