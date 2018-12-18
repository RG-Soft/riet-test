////////////////////////////////////////////////////////////////////////////////
// СЛУЖЕБНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ

// Функция возвращает имя основной формы ("ОсновнаяФорма" или "ОсновнаяФормаДополнительная"),
// используемой при открытии регл. отчета "РегламентированныйОтчетРСВ1".
// 
// Пример:
//  Возврат "ОсновнаяФормаДополнительная";
//
Функция ИмяОсновнойФормыРСВ1() Экспорт
	
	Возврат "ОсновнаяФормаДополнительная";
	
КонецФункции

///////////////////////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ИНТЕРФЕЙСА ВЗАИМОДЕЙСТВИЯ С КОНФИГУРАЦИЯМИ (БИБЛИОТЕКАМИ) - ПОТРЕБИТЕЛЯМИ
//

// Процедура определяет, будет ли доступно для редактирования поле "ВидДокументаПредставление"
// в форме РСВ-1.
//
// Параметры:
//  Доступность - булево.
//
Процедура ОпределитьДоступностьИзмененияВидаРСВ_1(Доступность) Экспорт
	//ПерсонифицированныйУчетКлиентСервер.ОпределитьДоступностьИзмененияВидаРСВ_1(Доступность);	
КонецПроцедуры