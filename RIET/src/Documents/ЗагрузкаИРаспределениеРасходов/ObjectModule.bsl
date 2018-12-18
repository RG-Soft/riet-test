
Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	Запрос = Новый Запрос("ВЫБРАТЬ
	                      |	ЗагрузкаРасходовПоЗарплатеЗатраты.НалоговаяРегистрация,
	                      |	СУММА(ЗагрузкаРасходовПоЗарплатеЗатраты.Расходы) КАК Расходы,
	                      |	СУММА(ЗагрузкаРасходовПоЗарплатеЗатраты.ПрочиеРасходы) КАК ПрочиеРасходы,
	                      |	СУММА(ЗагрузкаРасходовПоЗарплатеЗатраты.СтраховыеВзносы) КАК СтраховыеВзносы,
	                      |	СУММА(ЗагрузкаРасходовПоЗарплатеЗатраты.ВзносыФСС) КАК ВзносыФСС,
	                      |	ВЫБОР
	                      |		КОГДА ЗагрузкаРасходовПоЗарплатеЗатраты.ВидРасходов = ""прямые расходы""
	                      |			ТОГДА ИСТИНА
	                      |		ИНАЧЕ ЛОЖЬ
	                      |	КОНЕЦ КАК Прямые
	                      |ПОМЕСТИТЬ РасходыОбщие
	                      |ИЗ
	                      |	Документ.ЗагрузкаРасходовПоЗарплате.Затраты КАК ЗагрузкаРасходовПоЗарплатеЗатраты
	                      |ГДЕ
	                      |	ЗагрузкаРасходовПоЗарплатеЗатраты.Ссылка = &Ссылка
	                      |
	                      |СГРУППИРОВАТЬ ПО
	                      |	ЗагрузкаРасходовПоЗарплатеЗатраты.НалоговаяРегистрация,
	                      |	ВЫБОР
	                      |		КОГДА ЗагрузкаРасходовПоЗарплатеЗатраты.ВидРасходов = ""прямые расходы""
	                      |			ТОГДА ИСТИНА
	                      |		ИНАЧЕ ЛОЖЬ
	                      |	КОНЕЦ
	                      |;
	                      |
	                      |////////////////////////////////////////////////////////////////////////////////
	                      |ВЫБРАТЬ
	                      |	РасходыОбщие.НалоговаяРегистрация,
	                      |	РасходыОбщие.Расходы КАК Сумма,
	                      |	&РасходыПрямые КАК Тип
	                      |ПОМЕСТИТЬ ДляСворачивания
	                      |ИЗ
	                      |	РасходыОбщие КАК РасходыОбщие
	                      |ГДЕ
	                      |	РасходыОбщие.Прямые
	                      |
	                      |ОБЪЕДИНИТЬ ВСЕ
	                      |
	                      |ВЫБРАТЬ
	                      |	РасходыОбщие.НалоговаяРегистрация,
	                      |	РасходыОбщие.Расходы,
	                      |	&РасходыРаспр
	                      |ИЗ
	                      |	РасходыОбщие КАК РасходыОбщие
	                      |ГДЕ
	                      |	(НЕ РасходыОбщие.Прямые)
	                      |
	                      |ОБЪЕДИНИТЬ ВСЕ
	                      |
	                      |ВЫБРАТЬ
	                      |	РасходыОбщие.НалоговаяРегистрация,
	                      |	РасходыОбщие.ПрочиеРасходы,
	                      |	&ПрочиеРасходы
	                      |ИЗ
	                      |	РасходыОбщие КАК РасходыОбщие
	                      |
	                      |ОБЪЕДИНИТЬ ВСЕ
	                      |
	                      |ВЫБРАТЬ
	                      |	РасходыОбщие.НалоговаяРегистрация,
	                      |	РасходыОбщие.СтраховыеВзносы,
	                      |	&ЕСНпрямой
	                      |ИЗ
	                      |	РасходыОбщие КАК РасходыОбщие
	                      |ГДЕ
	                      |	(НЕ РасходыОбщие.Прямые)
	                      |
	                      |ОБЪЕДИНИТЬ ВСЕ
	                      |
	                      |ВЫБРАТЬ
	                      |	РасходыОбщие.НалоговаяРегистрация,
	                      |	РасходыОбщие.СтраховыеВзносы,
	                      |	&ЕСНраспр
	                      |ИЗ
	                      |	РасходыОбщие КАК РасходыОбщие
	                      |ГДЕ
	                      |	РасходыОбщие.Прямые
	                      |
	                      |ОБЪЕДИНИТЬ ВСЕ
	                      |
	                      |ВЫБРАТЬ
	                      |	РасходыОбщие.НалоговаяРегистрация,
	                      |	РасходыОбщие.ВзносыФСС,
	                      |	&ФСС
	                      |ИЗ
	                      |	РасходыОбщие КАК РасходыОбщие
	                      |;
	                      |
	                      |////////////////////////////////////////////////////////////////////////////////
	                      |ВЫБРАТЬ
	                      |	МИНИМУМ(КостЦентры.Ссылка) КАК Ссылка,
	                      |	КостЦентры.TaxRegistration
	                      |ПОМЕСТИТЬ АУ
	                      |ИЗ
	                      |	Справочник.КостЦентры КАК КостЦентры
	                      |
	                      |СГРУППИРОВАТЬ ПО
	                      |	КостЦентры.TaxRegistration
	                      |;
	                      |
	                      |////////////////////////////////////////////////////////////////////////////////
	                      |ВЫБРАТЬ
	                      |	ВложенныйЗапрос.НалоговаяРегистрация,
	                      |	ВложенныйЗапрос.Сумма,
	                      |	ВложенныйЗапрос.Тип,
	                      |	АУ.Ссылка КАК AU
	                      |ИЗ
	                      |	(ВЫБРАТЬ
	                      |		ДляСворачивания.НалоговаяРегистрация КАК НалоговаяРегистрация,
	                      |		СУММА(ДляСворачивания.Сумма) КАК Сумма,
	                      |		ДляСворачивания.Тип КАК Тип
	                      |	ИЗ
	                      |		ДляСворачивания КАК ДляСворачивания
	                      |	
	                      |	СГРУППИРОВАТЬ ПО
	                      |		ДляСворачивания.НалоговаяРегистрация,
	                      |		ДляСворачивания.Тип) КАК ВложенныйЗапрос
	                      |		ЛЕВОЕ СОЕДИНЕНИЕ АУ КАК АУ
	                      |		ПО ВложенныйЗапрос.НалоговаяРегистрация = АУ.TaxRegistration");
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("РасходыПрямые",	Справочники.СтатьиДоходовИРасходов.НайтиПоКоду("SAL_dir"));
	Запрос.УстановитьПараметр("РасходыРаспр",  	Справочники.СтатьиДоходовИРасходов.НайтиПоКоду("SAL_reall"));
	Запрос.УстановитьПараметр("ПрочиеРасходы",  Справочники.СтатьиДоходовИРасходов.НайтиПоКоду("SAL_Other"));
	Запрос.УстановитьПараметр("ЕСНпрямой",  	Справочники.СтатьиДоходовИРасходов.НайтиПоКоду("SAL_UST_d"));
	Запрос.УстановитьПараметр("ЕСНраспр",  		Справочники.СтатьиДоходовИРасходов.НайтиПоКоду("SAL_UST_r"));
	Запрос.УстановитьПараметр("ФСС",  			Справочники.СтатьиДоходовИРасходов.НайтиПоКоду("SAL_SIF"));
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	курсSLB = ОбщегоНазначения.ПолучитьКурсВалюты(Справочники.Валюты.НайтиПоКоду("999"), Дата).Курс;
	
	
	Пока выборка.Следующий() Цикл
		Движение = Движения.ПроводкиDSSОбщие.Добавить();
		Движение.Период = Дата;
		//Движение.AccountLawson = ПланыСчетов.Lawson.НайтиПоКоду("529703");
		Движение.AU = Выборка.AU;
		Движение.LegalEntity = Выборка.НалоговаяРегистрация;
		Движение.FiscalType = Выборка.Тип;
		Движение.BaseAmount = 0;
		Движение.RubAmount = Выборка.Сумма;
		Движение.FiscAmount = Выборка.Сумма / курсSLB;
		Движение.PermDiff =  - Движение.FiscAmount;
		Движение.Currency = Справочники.Валюты.НайтиПоКоду("643");
		Движение.Description = "расходы на оплату труда"; 	
		Движение.GltObjId = 1000000000;
		Движение.GUID = Новый УникальныйИдентификатор;
		Движение.Модуль = Перечисления.МодулиРазработки.Salary;
	КонецЦикла;
	
	Движения.ПроводкиDSSОбщие.Записать();
	
КонецПроцедуры

Функция ВернутьВидыНачислений(ТЗ) Экспорт 
	
	СтрокаЗаголовков = ТЗ[0];
	КолВоКолонок = ТЗ.Колонки.Количество();
	ТабЗаголовков = Новый ТаблицаЗначений;
	ТабЗаголовков.Колонки.Добавить("Заголовок", ОбщегоНазначения.ПолучитьОписаниеТиповСтроки(100));
	Для индК = 1 По КолВоКолонок Цикл
		ЗаголовокКолонки = СтрокаЗаголовков[индК-1]; 
		НоваяСтрока = ТабЗаголовков.Добавить();
		НоваяСтрока.Заголовок = ЗаголовокКолонки;
		//Сообщить(НоваяСтрока.Заголовок);
	КонецЦикла;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ                                           
		|	ТабЗаголовков.Заголовок 
		|ПОМЕСТИТЬ ВТ
		|ИЗ
		|	&ТабЗаголовков КАК ТабЗаголовков
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ.Заголовок КАК ВидНачисления
		|ИЗ
		|	ВТ КАК ВТ
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ВидыНачислений КАК ВидыНачислений
		|		ПО ВТ.Заголовок = ВидыНачислений.Наименование
		|ГДЕ
		|	ВидыНачислений.Ссылка ЕСТЬ NULL ";
		
	Запрос.УстановитьПараметр("ТабЗаголовков", ТабЗаголовков);	

	Результат = Запрос.Выполнить();
	
	Возврат Результат.Выгрузить();
	
КонецФункции	
