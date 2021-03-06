//Добавил РГ-Софт - Пронин Иван
Перем мУдалятьДвижения;
//Конец добавления

Процедура ОбработкаПроведения(Отказ, Режим)
	
	//Добавил РГ-Софт - Пронин Иван
	Если мУдалятьДвижения Тогда
		ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ,, Истина);
	КонецЕсли;
	//Конец добавления
	
	Если ВидОперации = Перечисления.ВидыОперацийСписаниеОборудования.ОборудованиеDSS Тогда
		Для Каждого СтрокаТЧ Из ОборудованиеDSS Цикл
			Движение = Движения.ОборудованиеDSS.Добавить();
			ЗаполнитьЗначенияСвойств(Движение, СтрокаТЧ);
			Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
			Движение.Период = Дата;
		КонецЦикла;
		Движение = Движения.ОборудованиеDSS.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
		Движение.Период = Дата;
		Движение.Номенклатура = Номенклатура;
		Движение.ПроводкаДеталейСКП = ПроводкаДеталейСКП;
		Движение.Сумма = ОборудованиеDSS.Итог("Сумма");
		Движение.СуммаРуб = ОборудованиеDSS.Итог("СуммаРуб");
		Движение.Количество = 0;
		Возврат;
	КонецЕсли;
	
	//Reclass FA to MnS
	Если ВидОперации = Перечисления.ВидыОперацийСписаниеОборудования.ReclassFAtoMnS Тогда
		Для Каждого СтрокаТЧ Из ОборудованиеDSS Цикл
			Движение = Движения.ОборудованиеDSS.ДобавитьРасход();
			ЗаполнитьЗначенияСвойств(Движение, СтрокаТЧ);
			Движение.Период = Дата;
			
			Движение = Движения.MaterialsAndSupplies.ДобавитьПриход();
			Движение.ПроводкаДеталейСКП = СтрокаТЧ.ПроводкаДеталейСКП;
			Движение.FiscalSum = СтрокаТЧ.СуммаРуб;
			Движение.ManagementSum = СтрокаТЧ.Сумма;
			Движение.Период = Дата;
		КонецЦикла;
	Возврат;	
	КонецЕсли;
	
	//Добавила Федотова Л., РГ-Софт, 24.05.13, вопрос SLI-0003596	                    
	//Reclass FA to CoGS
	Если ВидОперации = Перечисления.ВидыОперацийСписаниеОборудования.ReclassFAtoCoS Тогда
		Для Каждого СтрокаТЧ Из ОборудованиеDSS Цикл
			Движение = Движения.ОборудованиеDSS.ДобавитьРасход();
			ЗаполнитьЗначенияСвойств(Движение, СтрокаТЧ);
			Движение.Период = Дата;
			
			Движение = Движения.CoGS.ДобавитьПриход();
			Движение.СписаниеОборудования = Ссылка;
			Движение.ПроводкаДеталейСКП = СтрокаТЧ.ПроводкаДеталейСКП;
			Движение.Номенклатура = СтрокаТЧ.Номенклатура;
			Движение.Количество = СтрокаТЧ.Количество;
			Движение.FiscalSum = СтрокаТЧ.СуммаРуб;
			Движение.ManagementSum = СтрокаТЧ.Сумма;
			Движение.Период = Дата;
		КонецЦикла;
	Возврат;	
	КонецЕсли;
	
	//Ввод остатков
	Если ВидОперации = Перечисления.ВидыОперацийСписаниеОборудования.ВводОстатков Тогда
		Для Каждого СтрокаТЧ Из ОборудованиеDSS Цикл
			Движение = Движения.ОборудованиеDSS.ДобавитьПриход();
			ЗаполнитьЗначенияСвойств(Движение, СтрокаТЧ);
			Движение.Период = Дата;
		КонецЦикла;
	Возврат;	
	КонецЕсли;
               	
	Для Каждого ТекСтрокаСостав Из Состав Цикл
		Движение = Движения.ОборудованиеЛокальное.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Период = Дата;
		Движение.НомерНакладной = ТекСтрокаСостав.НомерНакладной;
		Движение.Поставщик = ТекСтрокаСостав.Поставщик;
		Движение.AU = ТекСтрокаСостав.AU;
		Движение.РО = ТекСтрокаСостав.РО;
		Движение.ДатаНакладной = ТекСтрокаСостав.ДатаНакладной;
		Движение.Подразделение = ТекСтрокаСостав.Подразделение;
		Движение.Сумма = ТекСтрокаСостав.Сумма;
	КонецЦикла;
	
	Для Каждого ТекСтрокаДекларации Из Декларации Цикл
		Если ВидОперации = Перечисления.ВидыОперацийСписаниеОборудования.Оборудование Тогда
			Движение = Движения.Оборудование.Добавить();
			Движение.Сумма = ТекСтрокаДекларации.Сумма;
		ИначеЕсли ВидОперации = Перечисления.ВидыОперацийСписаниеОборудования.ОборудованиеЭкспортное Тогда
			Движение = Движения.ОборудованиеЭкспорт.Добавить();
		КонецЕсли; 
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Период = Дата;
		Движение.Декларация = ТекСтрокаДекларации.Декларация;
		Движение.Номенклатура = ТекСтрокаДекларации.Номенклатура;
		Движение.AU = ТекСтрокаДекларации.AccountingUnit;
		Движение.НомерСтрокиГТД = ТекСтрокаДекларации.НомерСтрокиГТД;
		Движение.Количество = ТекСтрокаДекларации.Количество;
	КонецЦикла;
	   	
	//{{__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	// Данный фрагмент построен конструктором.
	// При повторном использовании конструктора, внесенные вручную изменения будут утеряны!!!
	//}}__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
КонецПроцедуры

Процедура ПередЗаписью(Отказ)
	Контрагент = "";
	РО = "";
	Контрагенты = Состав.Выгрузить();
	Контрагенты.Свернуть("Поставщик");
	Для каждого стр из Контрагенты цикл
		Контрагент = Контрагент + стр.Поставщик + " ";
	КонецЦикла;
	РОы = Состав.Выгрузить();
	РОы.Свернуть("РО");
	Для каждого стр из РОы цикл
		РО = РО + стр.РО + " ";
	КонецЦикла;
	
	//Добавил РГ-Софт - Пронин Иван
	мУдалятьДвижения = НЕ ЭтоНовый();
	//Конец добавления
КонецПроцедуры

//Добавил РГ-Софт - Пронин Иван
Процедура ОбработкаУдаленияПроведения(Отказ)
	
	ОбщегоНазначения.УдалитьДвиженияРегистратора(ЭтотОбъект, Отказ,, Истина);
	
КонецПроцедуры

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	Если ТипЗнч(ДанныеЗаполнения) = Тип("ТаблицаЗначений") Тогда 
		//ВидОперации = Перечисления.ВидыОперацийСписаниеОборудования.ReclassFAtoMnS;
		НастройкаПравДоступа.УстановитьДатуПроведенияДокумента(ЭтотОбъект);
	    НастройкаПравДоступа.УстановитьНалоговыйПериодДокумента(ЭтотОбъект);
		Для Каждого СтрокаТаблицы из ДанныеЗаполнения Цикл 
			НоваяСтр = ОборудованиеDSS.Добавить();
			НоваяСтр.ПроводкаДеталейСКП = СтрокаТаблицы.ПроводкаDSSДеталейСчетовКнигиПокупок;
			ЗаполнитьЗначенияСвойств(НоваяСтр,СтрокаТаблицы);
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры
