using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Presentacion.Reportes._2020.Ventas.Restaurant.forms
{
    public partial class ticket_pedidos : Imprimir
    {
        int _idMesa, idPiso;

        public int IdMesa { get => _idMesa; set => _idMesa = value; }
        public new int IdPiso { get => idPiso; set => idPiso = value; }

        public ticket_pedidos()
        {
            InitializeComponent();
        }

        private void ticket_pedidos_Load(object sender, EventArgs e)
        {
            Impresion();
            this.reportViewer1.RefreshReport();
        }

        void Impresion()
        {

        }
    }
}
