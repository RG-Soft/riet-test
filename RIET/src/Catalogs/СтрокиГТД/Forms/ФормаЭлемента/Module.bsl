
/////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ЗакрыватьПриЗакрытииВладельца = Истина;
		
	ОбщегоНазначенияКлиентСервер.ДобавитьЭлементКомпоновки(
		Goods.Отбор,
		"Владелец",
		ВидСравненияКомпоновкиДанных.Равно,
		Объект.Ссылка);
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////

&НаКлиенте
Процедура ПередЗаписью(Отказ, ПараметрыЗаписи)
	
	РГСофтКлиент.ПроверитьНеобходимостьЗаписиСправочника(Модифицированность, Отказ);
		 	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	ОбщегоНазначенияКлиентСервер.УстановитьЭлементОтбора(
		Goods.Отбор,
		"Владелец",
		Объект.Ссылка,
		ВидСравненияКомпоновкиДанных.Равно);
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////
// РЕКВИЗИТЫ ШАПКИ

&НаКлиенте
Процедура CalculateCustomsCost(Команда)
	
	Отказ = Ложь;
	
	Если ЗначениеЗаполнено(Объект.ТаможеннаяСтоимость) Тогда
		
		Ответ = Вопрос(
			"Вы действительно хотите изменить таможенную стоимость?",
			РежимДиалогаВопрос.ДаНет,
			60,
			КодВозвратаДиалога.Нет,
			"Внимание!",
			КодВозвратаДиалога.Нет);
			
		Если Ответ = КодВозвратаДиалога.Нет Тогда
			Отказ = Истина;
		КонецЕсли;
			
	КонецЕсли;
	
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
		
	Если НЕ ЗначениеЗаполнено(Объект.ГТД) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Поле ""CCD"" не заполнено!",
			, "ГТД", "Объект", Отказ);
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Объект.СтатистическаяСтоимость) Тогда
    	ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"Поле ""Statistical cost"" не заполнено!",
			, "СтатистическаяСтоимость", "Объект", Отказ);
	КонецЕсли;
		
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	Курс = ОбщегоНазначения.ПолучитьЗначениеРеквизита(Объект.ГТД, "ContractCurrencyRate");
	
	Если НЕ ЗначениеЗаполнено(Курс) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
			"""Contract currency rate"" in CCD is empty!",
			Объект.ГТД, "ContractCurrencyRate", , Отказ);
	КонецЕсли;
		
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	Объект.ТаможеннаяСтоимость = Объект.СтатистическаяСтоимость * Курс;
	Модифицированность = Истина;
	
КонецПроцедуры


/////////////////////////////////////////////////////////////////////////
// GOODS

&НаКлиенте
Процедура GoodsПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
	
	Если НЕ ЗначениеЗаполнено(Объект.Ссылка) Тогда
		
		Попытка
			Записать(Новый Структура);
		Исключение
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(
				"Не удалось добавить новый товар: не удалось записать строку ГТД: " + ОписаниеОшибки(),
				, , "Объект", Отказ);
		КонецПопытки;
		
	КонецЕсли;
	
КонецПроцедуры
