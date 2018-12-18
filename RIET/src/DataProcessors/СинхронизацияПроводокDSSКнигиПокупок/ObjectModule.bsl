
///////////////////////////////////////////////////////////////////////////////////////
// СЧЕТА КНИГИ ПОКУПОК

// ЗАГРУЗКА НОВЫХ ПРОВОДОК

Функция ПолучитьКоличествоНовыхПроводокШапкиСКП() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ ДокументПроводкаDSS.Ссылка) КАК КоличествоНовыхПроводок
		|ИЗ
		|	Документ.ПроводкаDSS КАК ДокументПроводкаDSS
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.СчетКнигиПокупок КАК СчетКнигиПокупок
		|		ПО ДокументПроводкаDSS.Ссылка = СчетКнигиПокупок.ПроводкаDSS
		|ГДЕ
		|	ДокументПроводкаDSS.Дата >= &Дата_01042012
		|	И ДокументПроводкаDSS.System = ""AP""
		|	И ДокументПроводкаDSS.Модуль = ЗНАЧЕНИЕ(Перечисление.МодулиРазработки.PurchaseBook)
		|	И ДокументПроводкаDSS.SourceCode = ""AC""
		|	И СчетКнигиПокупок.ПроводкаDSS ЕСТЬ NULL ";
	Запрос.УстановитьПараметр("Дата_01042012", '20120401'); //лучше не трогать старую книгу покупок
	
	РезультатЗапроса = Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();
	Выборка.Следующий();
	Возврат Выборка.КоличествоНовыхПроводок;
	
КонецФункции

Функция ПолучитьКоличествоНовыхInventoryПроводок() Экспорт
	
	Запрос = Новый Запрос; 
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ЕСТЬNULL(КОЛИЧЕСТВО(ПроводкиDSSДетали.GltObjId), 0) КАК КоличествоНовыхПроводок
		|ИЗ
		|	РегистрСведений.ПроводкиDSSДетали КАК ПроводкиDSSДетали
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ПроводкиDSSДеталейСчетовКнигиПокупок КАК ПроводкиDSSДеталейСчетовКнигиПокупок
		|		ПО ПроводкиDSSДетали.GltObjId = ПроводкиDSSДеталейСчетовКнигиПокупок.Код
		|ГДЕ
		|	ПроводкиDSSДетали.Модуль = ЗНАЧЕНИЕ(Перечисление.МодулиРазработки.InventoryCosts)
		|	И ПроводкиDSSДеталейСчетовКнигиПокупок.Код ЕСТЬ NULL";
	
	РезультатЗапроса = Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();
	Выборка.Следующий();
	Возврат Выборка.КоличествоНовыхПроводок;
	
КонецФункции
     
// ПОМЕТКА НА УДАЛЕНИЕ СТАРЫХ ПРОВОДОК

// ДОДЕЛАТЬ!!!
Функция ПолучитьКоличествоСтарыхПроводокШапкиСКП() Экспорт
	
	Запрос = Новый Запрос;
	// НУЖЕН ИНДЕКС ПО МОДУЛЮ!!!
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ЕСТЬNULL(КОЛИЧЕСТВО(СчетКнигиПокупок.Ссылка), 0) КАК КоличествоСтарыхПроводок
		|ИЗ
		|	Документ.СчетКнигиПокупок КАК СчетКнигиПокупок
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ПроводкаDSS КАК ДокументПроводкаDSS
		|		ПО СчетКнигиПокупок.ПроводкаDSS.Номер = ДокументПроводкаDSS.Номер
		|ГДЕ
		|	(НЕ СчетКнигиПокупок.ПометкаУдаления)
		|	И (ДокументПроводкаDSS.Модуль ЕСТЬ NULL 
		|			ИЛИ СчетКнигиПокупок.ПроводкаDSS.Модуль <> ЗНАЧЕНИЕ(Перечисление.МодулиРазработки.PurchaseBook))
		|	И (НЕ СчетКнигиПокупок.ЗагруженИзExcel)";
		
	РезультатЗапроса = Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();
	Выборка.Следующий();
	Возврат Выборка.КоличествоСтарыхПроводок;	
	
КонецФункции

///////////////////////////////////////////////////////////////////////////////////////
// ОПЛАТЫ КНИГИ ПОКУПОК

// ЗАГРУЗКА НОВЫХ ПРОВОДОК

// ДОДЕЛАТЬ!!!
Функция ПолучитьКоличествоНовыхПроводокОКП() Экспорт
	
	Запрос = Новый Запрос;
	// ПОСТАВИТЬ НОРМАЛЬНОЕ УСЛОВИЕ НА МОДУЛЬ!!!
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ ПроводкаDSS.Ссылка) КАК КоличествоНовыхПроводок
		|ИЗ
		|	Документ.ПроводкаDSS КАК ПроводкаDSS
		|ГДЕ
		|	ПроводкаDSS.Модуль = ЗНАЧЕНИЕ(Перечисление.МодулиРазработки.PurchaseBook)
		|	И (ПроводкаDSS.SourceCode = ""AP""
		|			ИЛИ ПроводкаDSS.SourceCode = ""VP"")
		|	И (ПроводкаDSS.Документ ЕСТЬ NULL 
		|			ИЛИ ПроводкаDSS.Документ = НЕОПРЕДЕЛЕНО)
		|	И НЕ ПроводкаDSS.ПометкаУдаления";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Выборка.Следующий();
	Возврат Выборка.КоличествоНовыхПроводок;
	
КонецФункции

// ПОМЕТКА НА УДАЛЕНИЕ СТАРЫХ ПРОВОДОК

// ДОДЕЛАТЬ!!!
Функция ПолучитьКоличествоСтарыхПроводокОКП() Экспорт
	
	Запрос = Новый Запрос;
	// НУЖЕН ИНДЕКС ПО МОДУЛЮ!!!
	Запрос.Текст =
		"ВЫБРАТЬ
		|	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ ОплатаКнигиПокупок.Ссылка) КАК КоличествоСтарыхПроводок
		|ИЗ
		|	Документ.ОплатаКнигиПокупок КАК ОплатаКнигиПокупок
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.ПроводкаDSS КАК ПроводкаDSS
		|		ПО (ПроводкаDSS.Документ = ОплатаКнигиПокупок.Ссылка)
		|ГДЕ
		|	(ПроводкаDSS.Ссылка ЕСТЬ NULL 
		|			ИЛИ ПроводкаDSS.Ссылка = НЕОПРЕДЕЛЕНО
		|			ИЛИ ПроводкаDSS.ПометкаУдаления)
		|	И (НЕ ОплатаКнигиПокупок.ПометкаУдаления)";

		
	РезультатЗапроса = Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();
	Выборка.Следующий();
	Возврат Выборка.КоличествоСтарыхПроводок;
	
КонецФункции

Функция ПолучитьКоличествоНепривязанныхПроводок() Экспорт

	Запрос = Новый Запрос("ВЫБРАТЬ РАЗЛИЧНЫЕ
	                      |	КОЛИЧЕСТВО(РАЗЛИЧНЫЕ ПроводкаDSS.Ссылка) КАК КоличествоНовыхПроводок
	                      |ИЗ
	                      |	Документ.ПроводкаDSS КАК ПроводкаDSS
	                      |ГДЕ
	                      |	ПроводкаDSS.System = ""AP""
	                      |	И (ПроводкаDSS.Документ = ЗНАЧЕНИЕ(Документ.СчетКнигиПокупок.ПустаяСсылка)
	                      |			ИЛИ ПроводкаDSS.Документ ССЫЛКА Документ.ОперацияLawson
	                      |			ИЛИ ПроводкаDSS.Документ = НЕОПРЕДЕЛЕНО)
	                      |	И (НЕ ПроводкаDSS.ПометкаУдаления)
	                      |	И (ПроводкаDSS.SourceCode = ""AD""
	                      |			ИЛИ ПроводкаDSS.SourceCode = ""XC"")
	                      |
	                      |ДЛЯ ИЗМЕНЕНИЯ
	                      |	Документ.ПроводкаDSS");
						   
	Выборка = Запрос.Выполнить().Выбрать();
	Выборка.Следующий();
	Возврат Выборка.КоличествоНовыхПроводок;
	
КонецФункции

