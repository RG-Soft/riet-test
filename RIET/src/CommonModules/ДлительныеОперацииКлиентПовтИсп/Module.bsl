////////////////////////////////////////////////////////////////////////////////
// Подсистема "Базовая функциональность".
// Поддержка работы длительных серверных операций в веб-клиенте.
//  
////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

// Получить форму-индикатор выполнения длительной операции.
//
Функция ФормаДлительнойОперации() Экспорт
	
	Возврат ПолучитьФорму("ОбщаяФорма.ДлительнаяОперация");
	
КонецФункции

#КонецОбласти
