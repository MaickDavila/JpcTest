using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Presentacion.Reportes._2020.Reportes.ReporteGeneralPagosNotasSalida.form
{
    public partial class ReporteGeneralPagosSalidasForm : Imprimir
    {
        DateTime _FechaInicio, _FechaFin;
        public int IdCliente { set; get; }

        public ReporteGeneralPagosSalidasForm()
        {
            InitializeComponent();
        }

        public DateTime FechaInicio { get => _FechaInicio; set => _FechaInicio = value; }
        public DateTime FechaFin { get => _FechaFin; set => _FechaFin = value; }


        private void ReporteGeneralPagosSalidasForm_Load(object sender, EventArgs e)
        {
            Imprimir();
            this.reportViewer1.RefreshReport();
        }
        void Imprimir()
        {
            try
            {

                //ReporteGeneralPagosNotasSalida.DataSet.ReporteGeneralPagosSalidasDataSetTableAdapters.sp_reporte_general_pagos_notas_salidasTableAdapter ta = new DataSet.ReporteGeneralPagosSalidasDataSetTableAdapters.sp_reporte_general_pagos_notas_salidasTableAdapter();
                //ta.Connection = new System.Data.SqlClient.SqlConnection(DataSetConexion);                

                //ReporteGeneralPagosNotasSalida.DataSet.ReporteGeneralPagosSalidasDataSet.sp_reporte_general_pagos_notas_salidasDataTable tabla = new DataSet.ReporteGeneralPagosSalidasDataSet.sp_reporte_general_pagos_notas_salidasDataTable();                
                //ta.Fill(tabla, FechaInicio, FechaFin);                 

                DataTable tabla = new DataTable();

                tabla = N_Reportes.sp_reporte_general_pagos_notas_salidas(FechaInicio, FechaFin, IdCliente);

                ParametrosReporte("DataSet1", (DataTable)tabla, "2020\\Reportes\\ReporteGeneralPagosNotasSalida\\ReporteGeneralPagosSalidas.rdlc", reportViewer1);

            }
            catch (Exception ex)
            {
                string es = ex.Message;
            }

        }
    }
}
