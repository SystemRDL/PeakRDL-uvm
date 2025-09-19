from typing import TYPE_CHECKING

from peakrdl.plugins.exporter import ExporterSubcommandPlugin #pylint: disable=import-error
from peakrdl.config import schema #pylint: disable=import-error

from .exporter import UVMExporter

if TYPE_CHECKING:
    import argparse
    from systemrdl.node import AddrmapNode


class Exporter(ExporterSubcommandPlugin):
    short_desc = "Generate a UVM register model"

    cfg_schema = {
        "user_template_dir": schema.DirectoryPath(),
        "user_template_context": schema.UserMapping(schema.String()),
    }


    def add_exporter_arguments(self, arg_group: 'argparse.ArgumentParser') -> None:
        arg_group.add_argument(
            "--file-type",
            dest="file_type",
            choices=['package', 'header'],
            default="package",
            help="Choose the file container style of the register model. [package]"
        )

        arg_group.add_argument(
            "--type-style",
            dest="type_style",
            choices=['lexical', 'hier'],
            default="lexical",
            help="""Choose how class type names are generated.
            The 'lexical' style will use RDL lexical scope & type names where
            possible and attempt to re-use equivalent class definitions.
            The 'hier' style uses component's hierarchy as the class type name. [lexical]
            """
        )

        arg_group.add_argument(
            "--use-factory",
            dest="use_factory",
            default=False,
            action="store_true",
            help="If set, class definitions and class instances are created using the UVM factory"
        )

        arg_group.add_argument(
            "--covearge",
            dest="covearge",
            default=False,
            action="store_true",
            help="If set, covergroup and sample function for accesses to registers are declared"
        )


    def do_export(self, top_node: 'AddrmapNode', options: 'argparse.Namespace') -> None:
        x = UVMExporter(
            user_template_dir=self.cfg['user_template_dir'],
            user_template_context=self.cfg['user_template_context']
        )
        x.export(
            top_node,
            options.output,
            export_as_package=(options.file_type == "package"),
            reuse_class_definitions=(options.type_style == "lexical"),
            use_uvm_factory=options.use_factory,
            coverage=options.coverage
        )
