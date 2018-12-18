
Функция ЗаполнитьПустуюPOLine(Знач PO, Good)  Экспорт
		
	POLine = Неопределено;
	
	//проверяем заполнение PO Number
	Если НЕ ЗначениеЗаполнено(PO) Тогда
		Возврат "Не заполнен PO!"; 
	КонецЕсли;	
			
	//получаем все строки PO по PO Number
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("PO", PO);	
	Запрос.Текст =
		"ВЫБРАТЬ
		|	СтрокиЗаявкиНаЗакупку.КодПоставщика КАК Supplier,
		|	СтрокиЗаявкиНаЗакупку.Ссылка КАК POLine
		|ИЗ
		|	Справочник.СтрокиЗаявкиНаЗакупку КАК СтрокиЗаявкиНаЗакупку
		|ГДЕ
		|	СтрокиЗаявкиНаЗакупку.Владелец = &PO
		|	И (НЕ СтрокиЗаявкиНаЗакупку.ПометкаУдаления)
		|	И (НЕ СтрокиЗаявкиНаЗакупку.Владелец.ПометкаУдаления)";
	
	ТаблицаСтрокPO = Запрос.Выполнить().Выгрузить();
		
	//Среди найденных PO lines ищется та, у которой Supplier P / N совпадает с кодом Good из строки документа. 
	//Если таких строк нет или найдено несколько строк - выдается сообщение об ошибке
	
	КолвоСтрокPO = ТаблицаСтрокPO.Количество();	
	Если КолвоСтрокPO = 0 Тогда
		
		Возврат "Не найдено PO lines в PO """ + PO + """"; 	
		
	ИначеЕсли КолвоСтрокPO = 1 Тогда
		
		POLine = ТаблицаСтрокPO[0].POLine;
		
	Иначе 
		
		НайденныеСтроки = ТаблицаСтрокPO.НайтиСтроки(Новый Структура("Supplier", СокрЛП(Good.Код)));
		Если НайденныеСтроки.Количество() = 1 Тогда 
			POLine = НайденныеСтроки[0].POLine;
		Иначе 
			Возврат "Не найдено или найдено несколько строк с Supplier P / N """ + СокрЛП(Good.Код) + """"; 
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат POLine; 	
	
КонецФункции

Процедура СформироватьПриходInventoryTangibleAssetsCosts(Ссылка, Дата) Экспорт 
	
	//записываем проводки IC
	ДвиженияInventory = РегистрыНакопления.InventoryTangibleAssetsCosts.СоздатьНаборЗаписей();
    ДвиженияInventory.Отбор.Регистратор.Установить(Ссылка);
	ДвиженияInventory.Записывать = Истина;
		
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("AccountLawsonRNI", ПланыСчетов.Lawson.НайтиПоКоду("201900"));
	Запрос.УстановитьПараметр("AccountLawsonINR", ПланыСчетов.Lawson.НайтиПоКоду("130508"));
	Запрос.УстановитьПараметр("AccountLawsonICO", ПланыСчетов.Lawson.НайтиПоКоду("130004"));
    Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("ДатаДок", Дата);
	Запрос.УстановитьПараметр("ВалютаSLB", Справочники.Валюты.НайтиПоКоду("999"));
	Запрос.УстановитьПараметр("ВалютаРуб", Справочники.Валюты.НайтиПоКоду("643"));
	Запрос.Текст = "ВЫБРАТЬ
	               |	КурсыВалютСрезПоследних.Курс
	               |ПОМЕСТИТЬ КурсSLB
	               |ИЗ
	               |	РегистрСведений.КурсыВалют.СрезПоследних(&ДатаДок, Валюта = &ВалютаSLB) КАК КурсыВалютСрезПоследних
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ПроводкиDSSДеталейСчетовКнигиПокупок.Ссылка КАК ПроводкаДеталейСКП,
	               |	ПроводкиDSSДеталейСчетовКнигиПокупок.BaseAmount КАК ManagementSum,
	               |	ПроводкиDSSДеталейСчетовКнигиПокупок.PeriodLawson КАК Период,
	               |	ВЫРАЗИТЬ(ПроводкиDSSДеталейСчетовКнигиПокупок.Description КАК СТРОКА(30)) КАК Описание
	               |ПОМЕСТИТЬ ПроводкиДеталей
	               |ИЗ
	               |	Документ.ПроводкаDSS КАК ПроводкиDSSДеталейСчетовКнигиПокупок
	               |ГДЕ
	               |	(ПроводкиDSSДеталейСчетовКнигиПокупок.AccountLawson = &AccountLawsonRNI
	               |			ИЛИ ПроводкиDSSДеталейСчетовКнигиПокупок.AccountLawson = &AccountLawsonINR
	               |			ИЛИ ПроводкиDSSДеталейСчетовКнигиПокупок.AccountLawson = &AccountLawsonICO)
	               |	И ПроводкиDSSДеталейСчетовКнигиПокупок.System = ""IC""
	               |	И ПроводкиDSSДеталейСчетовКнигиПокупок.Документ = &Ссылка
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ПроводкиДеталей.Описание КАК ItemCode,
	               |	СУММА(ПроводкиДеталей.ManagementSum) КАК ManagementSum
	               |ИЗ
	               |	ПроводкиДеталей КАК ПроводкиДеталей
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	ПроводкиДеталей.Описание
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	СУММА(InventoryПоступлениеGoods.FiscalSum) КАК FiscalSum,
	               |	InventoryПоступлениеGoods.Ссылка КАК Поступление,
	               |	InventoryПоступлениеGoods.Good,
	               |	ВЫРАЗИТЬ(InventoryПоступлениеGoods.Good.Код КАК СТРОКА(30)) КАК GoodКод,
	               |	InventoryПоступлениеGoods.Quantity КАК Количество
	               |ПОМЕСТИТЬ СтрокиInventory
	               |ИЗ
	               |	Документ.InventoryПоступление.Goods КАК InventoryПоступлениеGoods
	               |ГДЕ
	               |	InventoryПоступлениеGoods.Ссылка = &Ссылка
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	ВЫРАЗИТЬ(InventoryПоступлениеGoods.Good.Код КАК СТРОКА(30)),
	               |	InventoryПоступлениеGoods.Ссылка,
	               |	InventoryПоступлениеGoods.Good,
	               |	InventoryПоступлениеGoods.Quantity
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ПроводкиДеталей.ПроводкаДеталейСКП КАК ПроводкаДеталейСКП,
	               |	ПроводкиДеталей.Период,
	               |	ПроводкиДеталей.ManagementSum КАК ManagementSum,
	               |	ВЫБОР
	               |		КОГДА СтрокиInventory.FiscalSum = 0
	               |			ТОГДА ВЫБОР
	               |					КОГДА ПроводкиДеталей.ПроводкаДеталейСКП.Currency = &ВалютаРуб
	               |						ТОГДА ПроводкиДеталей.ПроводкаДеталейСКП.TranAmount
	               |					ИНАЧЕ ПроводкиДеталей.ПроводкаДеталейСКП.BaseAmount * КурсSLB.Курс
	               |				КОНЕЦ
	               |		ИНАЧЕ СтрокиInventory.FiscalSum
	               |	КОНЕЦ КАК FiscalSum,
	               |	ПроводкиДеталей.Описание КАК ItemCode,
	               |	СтрокиInventory.Количество
	               |ПОМЕСТИТЬ ВТРезультат
	               |ИЗ
	               |	ПроводкиДеталей КАК ПроводкиДеталей
	               |		ВНУТРЕННЕЕ СОЕДИНЕНИЕ СтрокиInventory КАК СтрокиInventory
	               |		ПО (СтрокиInventory.GoodКод ПОДОБНО ""%"" + ПроводкиДеталей.Описание + ""%""),
	               |	КурсSLB КАК КурсSLB
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ВТРезультат.ПроводкаДеталейСКП,
	               |	ВТРезультат.Период,
	               |	ВТРезультат.ManagementSum,
	               |	ВЫБОР
	               |		КОГДА ВТРезультат.ManagementSum > 0
	               |					И ВТРезультат.FiscalSum > 0
	               |				ИЛИ ВТРезультат.ManagementSum < 0
	               |					И ВТРезультат.FiscalSum < 0
	               |			ТОГДА ВТРезультат.FiscalSum
	               |		ИНАЧЕ -ВТРезультат.FiscalSum
	               |	КОНЕЦ КАК FiscalSum,
	               |	ВТРезультат.ItemCode,
	               |	ВТРезультат.Количество
	               |ИЗ
	               |	ВТРезультат КАК ВТРезультат";
	
	Результат = Запрос.ВыполнитьПакет();			   
	Выборка = Результат[5].Выбрать();
	ТЗManagementSumВСуммеПоItemCode = Результат[2].Выгрузить();
	
	СтруктураОтбора = Новый Структура;
	Пока Выборка.Следующий() Цикл 
		Движение = ДвиженияInventory.ДобавитьПриход();
		Движение.Период = Выборка.Период;                           
		Движение.ПроводкаДеталейСКП = Выборка.ПроводкаДеталейСКП;
		Движение.Количество = Выборка.Количество;
		Движение.ManagementSum = Выборка.ManagementSum;
		
		СтруктураОтбора.Вставить("ItemCode", Выборка.ItemCode);
		СтрокиТЗ = ТЗManagementSumВСуммеПоItemCode.НайтиСтроки(СтруктураОтбора);
		Движение.FiscalSum = ?(СтрокиТЗ[0].ManagementSum = 0, Выборка.FiscalSum, 
		                        Выборка.FiscalSum * Выборка.ManagementSum/СтрокиТЗ[0].ManagementSum);
	КонецЦикла;
	
	ДвиженияInventory.Записать();
	
	////проверяем количество строк
	//ДвиженияInventory.Записать();
	//Запрос = Новый Запрос;
	//Запрос.Текст = "ВЫБРАТЬ
	//			   |	КОЛИЧЕСТВО(ЕСТЬNULL(СтрокиInventoryПоступлений.Good, 0)) КАК КоличествоСтрок,
	//			   |	СтрокиInventoryПоступлений.Поступление.Представление КАК Представление
	//			   |ИЗ
	//			   |	Справочник.СтрокиInventoryПоступлений КАК СтрокиInventoryПоступлений
	//			   |ГДЕ
	//			   |	СтрокиInventoryПоступлений.Поступление = &Ссылка
	//			   |
	//			   |СГРУППИРОВАТЬ ПО
	//			   |	СтрокиInventoryПоступлений.Поступление.Представление";
	//
	//Запрос.УстановитьПараметр("Ссылка", Ссылка);
	//
	//Выборка = Запрос.Выполнить().Выбрать();
	//Выборка.Следующий();
	//
	//Если Выборка.КоличествоСтрок <> Результат.Количество() Тогда 
	//	
	//	ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Количество строк в документе " + Выборка.Представление + ":
	//	|("+Выборка.КоличествоСтрок+") не совпадает с количеством проводок DSS ("+Результат.Количество()+")!");
	//	
	//КонецЕсли;
    	
КонецПроцедуры

 Функция ПолучитьFiscalSumПоДокументуInventoryПартия(СтрокаСКП, СтрокаInventory) Экспорт 
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("PoNumber", СтрокаInventory.PoNumber);
	Запрос.УстановитьПараметр("ItemCode", СтрокаInventory.ItemCode);
	
	Запрос.Текст = "ВЫБРАТЬ
	               |	InventoryПартия.Ссылка
	               |ИЗ
	               |	Документ.InventoryПартия КАК InventoryПартия
	               |ГДЕ
	               |	InventoryПартия.PoNumber = &PoNumber
	               |	И InventoryПартия.ItemCode = &ItemCode
	               |	И (НЕ InventoryПартия.Ссылка.ПометкаУдаления)";
	
	Результат = Запрос.Выполнить().Выгрузить();
	
	
	// проверяем наличие документа
	Если Результат.Количество() > 0 Тогда 
		
		ДокументInventoryПартия = Результат[0].Ссылка.ПолучитьОбъект();
		
		// проверяем наличие проводки IC в документе, если нет - добавляем
		СтрокаПроводкиДеталейСКП = ДокументInventoryПартия.Проводки.Найти(СтрокаInventory.ПроводкаДеталейСКП, "ПроводкаДеталейСКП");
		Если СтрокаПроводкиДеталейСКП = Неопределено Тогда 
			НоваяСтрока = ДокументInventoryПартия.Проводки.Добавить();
			НоваяСтрока.ПроводкаДеталейСКП = СтрокаInventory.ПроводкаДеталейСКП;
			НоваяСтрока.FiscalSum = СтрокаInventory.FiscalSum;
	        НоваяСтрока.ManagementSum = СтрокаInventory.ManagementSum;
			НоваяСтрока.Количество = СтрокаInventory.Количество;
		иначе
			СтрокаПроводкиДеталейСКП.FiscalSum = СтрокаInventory.FiscalSum;
	        СтрокаПроводкиДеталейСКП.ManagementSum = СтрокаInventory.ManagementSum;
			СтрокаПроводкиДеталейСКП.Количество = СтрокаInventory.Количество;
		КонецЕсли;
		
		РежимЗаписи = ?(ДокументInventoryПартия.Проведен, РежимЗаписиДокумента.ОтменаПроведения, РежимЗаписиДокумента.Запись);
		
	иначе
		//создаем новый документ
		ДокументInventoryПартия = Документы.InventoryПартия.СоздатьДокумент();
		ДокументInventoryПартия.Дата = СтрокаInventory.Период;
		ДокументInventoryПартия.ItemCode = СтрокаInventory.ItemCode;
		ДокументInventoryПартия.PoNumber = СтрокаInventory.PoNumber; 
		НоваяСтрока = ДокументInventoryПартия.Проводки.Добавить();
		НоваяСтрока.ПроводкаДеталейСКП = СтрокаInventory.ПроводкаДеталейСКП;
		НоваяСтрока.FiscalSum = СтрокаInventory.FiscalSum;
	    НоваяСтрока.ManagementSum = СтрокаInventory.ManagementSum;
		НоваяСтрока.Количество = СтрокаInventory.Количество;
		
		РежимЗаписи = РежимЗаписиДокумента.Запись;
		
	КонецЕсли;	
		        	
	//поиск AP проводок
	
	Если СтрокаСКП.Количество() > 1 Тогда 
		
		Для Каждого Стр из СтрокаСКП Цикл 
			// проверяем наличие проводки AP в документе, если нет - добавляем
			СтрокаПроводкиДеталейСКП = ДокументInventoryПартия.Проводки.Найти(Стр.ПроводкаДеталейСКП, "ПроводкаДеталейСКП");
			Если СтрокаПроводкиДеталейСКП = Неопределено Тогда
				НоваяСтрока = ДокументInventoryПартия.Проводки.Добавить();
				НоваяСтрока.ПроводкаДеталейСКП = Стр.ПроводкаДеталейСКП;
				НоваяСтрока.FiscalSum = Стр.FiscalSum;
			    НоваяСтрока.ManagementSum = Стр.ManagementSum;
				НоваяСтрока.Количество = Стр.Количество;
			КонецЕсли;
		КонецЦикла;
		
		ВозвращаемоеЗначение = "Найдено несколько строк с одинаковым реквизитом Code: "+ СтрокаInventory.ItemCode +"!";
				
	ИначеЕсли  СтрокаСКП.Количество() = 0 Тогда
		
		ВозвращаемоеЗначение = "Не найдено строк из распределения материалов по Code: "+ СтрокаInventory.ItemCode + ".";
				
	ИначеЕсли  СтрокаСКП.Количество() = 1 Тогда
		СтрокаСКП = СтрокаСКП[0];
		// проверяем наличие проводки AP в документе, если нет - добавляем
		СтрокаПроводкиДеталейСКП = ДокументInventoryПартия.Проводки.Найти(СтрокаСКП.ПроводкаДеталейСКП, "ПроводкаДеталейСКП");
		Если СтрокаПроводкиДеталейСКП = Неопределено Тогда
			НоваяСтрока = ДокументInventoryПартия.Проводки.Добавить();
			НоваяСтрока.ПроводкаДеталейСКП = СтрокаСКП.ПроводкаДеталейСКП;
			НоваяСтрока.FiscalSum = СтрокаСКП.FiscalSum;
			НоваяСтрока.ManagementSum = СтрокаСКП.ManagementSum;
			НоваяСтрока.Количество = СтрокаСКП.Количество;
		КонецЕсли;

		Если (СтрокаInventory.FiscalSum + СтрокаСКП.FiscalSum) / Макс(СтрокаСКП.FiscalSum,СтрокаInventory.FiscalSum) < 0.1  тогда
			 ВозвращаемоеЗначение = СтрокаСКП.FiscalSum;
			 
			 РежимЗаписи = РежимЗаписиДокумента.Проведение;
		иначе
			 ВозвращаемоеЗначение = "Fiscal sum проводок с Code: "+ СтрокаInventory.ItemCode +" отличаются больше, чем на 10%!";
		КонецЕсли;
		   				
	КонецЕсли;
	    	
	InventoryСервер.ЗаписатьДокументВВыбранномРежиме(ДокументInventoryПартия,РежимЗаписи);
		
	Возврат ВозвращаемоеЗначение;
    	
КонецФункции 