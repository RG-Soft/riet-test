
Процедура ОбработкаПроведения(Отказ, Режим)
	//{{__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
	// This fragment was built by the wizard.
	// Warning! All manually made changes will be lost next time you use the wizard.
	Для Каждого ТекСтрокаКурсовыеРазницы Из КурсовыеРазницы Цикл
		// register КурсовыеРазницы Расход
		Движение = Движения.КурсовыеРазницы.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Период = Дата;
		Движение.Контрагент = ТекСтрокаКурсовыеРазницы.Контрагент;
		Движение.НомерСчета = ТекСтрокаКурсовыеРазницы.НомерСчета;
		Движение.ДатаСчета = ТекСтрокаКурсовыеРазницы.ДатаСчета;
		Движение.ВалютаСчета = ТекСтрокаКурсовыеРазницы.ВалютаСчета;
		//Движение.AU = ТекСтрокаКурсовыеРазницы.AU;
		Движение.CashCode = CashCode;
		//Движение.Подразделение = ТекСтрокаКурсовыеРазницы.Подразделение;
		Движение.КурсоваяРазница = ТекСтрокаКурсовыеРазницы.КурсоваяРазница;
		Движение.НомерВаучера = ТекСтрокаКурсовыеРазницы.НомерВаучера;
		
		Движение = Движения.Хозрасчетный.Добавить();
		Движение.Организация = Организация;
		//Движение.СчетДт 	= ПланыСчетов.Хозрасчетный.КурсовыеРазницы;
		Движение.СчетКт 	= ПланыСчетов.Хозрасчетный.РасчетыСПоставщиками;
		Движение.Период 	= Дата;
		Движение.Сумма 		= ТекСтрокаКурсовыеРазницы.КурсоваяРазница;
		Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Контрагенты] = ТекСтрокаКурсовыеРазницы.Контрагент;
		Движение.Содержание = "По ваучеру " + ТекСтрокаКурсовыеРазницы.НомерВаучера;
       
	КонецЦикла;
	// writing register movements
	Движения.КурсовыеРазницы.Записать();
	Движения.Хозрасчетный.Записать();
	//}}__КОНСТРУКТОР_ДВИЖЕНИЙ_РЕГИСТРОВ
КонецПроцедуры
