
#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура Выбрать(Команда)
	
	Закрыть(Элементы.ТаблицаНО.ТекущиеДанные);
	
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаНОВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	Закрыть(Элементы.ТаблицаНО.ТекущиеДанные);
	
КонецПроцедуры
    
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	// Пропускаем инициализацию, чтобы гарантировать получение формы при передаче параметра "АвтоТест".
	Если Параметры.Свойство("АвтоТест") Тогда
		Возврат;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ РАЗРЕШЕННЫЕ
	               |	СправочникИФНС.Ссылка КАК Ссылка,
				   |	СправочникИФНС.КПП КАК КПП,
	               |	СправочникИФНС.Код КАК КодНО,
				   |	СправочникИФНС.НаименованиеИФНС КАК Наименование,
	               |	СправочникИФНС.Представитель КАК Представитель
	               |ИЗ
	               |	Справочник.РегистрацииВНалоговомОргане КАК СправочникИФНС
	               |ГДЕ
	               |	(СправочникИФНС.Владелец = &Организация
				   |			ИЛИ СправочникИФНС.Владелец = &ГоловнаяОрганизация)
	               |	И НЕ СправочникИФНС.ПометкаУдаления
	               |
	               |УПОРЯДОЧИТЬ ПО
	               |	КодНО,
	               |	КПП";
	Запрос.УстановитьПараметр("Организация", Параметры.Организация);
	Запрос.УстановитьПараметр("ГоловнаяОрганизация", РегламентированнаяОтчетность.ГоловнаяОрганизация(Параметры.Организация));
		
	ТаблицаНО.Загрузить(Запрос.Выполнить().Выгрузить());
	
	НайденныеНО = ТаблицаНО.НайтиСтроки(Параметры.ЗначенияДляОтбора[0]);
	
	Если НайденныеНО.Количество() > 0 Тогда
		Элементы.ТаблицаНО.ТекущаяСтрока = НайденныеНО[0].ПолучитьИдентификатор();
	КонецЕсли;
				
КонецПроцедуры

#КонецОбласти