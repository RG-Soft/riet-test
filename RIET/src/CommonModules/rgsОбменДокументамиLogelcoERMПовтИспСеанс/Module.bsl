
Функция ПолучитьУзелERM() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	rgsОбменДокументамиLogelcoERM.Ссылка
		|ИЗ
		|	ПланОбмена.rgsОбменДокументамиLogelcoERM КАК rgsОбменДокументамиLogelcoERM
		|ГДЕ
		|	НЕ rgsОбменДокументамиLogelcoERM.ЭтотУзел
		|	И НЕ rgsОбменДокументамиLogelcoERM.ПометкаУдаления
		|	И rgsОбменДокументамиLogelcoERM.Код = ""ER""";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	ВыборкаДетальныеЗаписи.Следующий();
	
	Возврат ВыборкаДетальныеЗаписи.Ссылка;
	
КонецФункции