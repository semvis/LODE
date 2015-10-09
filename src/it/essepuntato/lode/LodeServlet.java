package it.essepuntato.lode;

import java.io.*;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerFactoryConfigurationError;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.mindswap.pellet.PelletOptions;
import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.io.RDFXMLOntologyFormat;
import org.semanticweb.owlapi.io.StringDocumentSource;
import org.semanticweb.owlapi.io.StringDocumentTarget;
import org.semanticweb.owlapi.model.AddAxiom;
import org.semanticweb.owlapi.model.AddImport;
import org.semanticweb.owlapi.model.AddOntologyAnnotation;
import org.semanticweb.owlapi.model.OWLAnnotation;
import org.semanticweb.owlapi.model.OWLAnnotationAssertionAxiom;
import org.semanticweb.owlapi.model.OWLAnnotationProperty;
import org.semanticweb.owlapi.model.OWLAnnotationSubject;
import org.semanticweb.owlapi.model.OWLAxiom;
import org.semanticweb.owlapi.model.OWLClass;
import org.semanticweb.owlapi.model.OWLDataProperty;
import org.semanticweb.owlapi.model.OWLDatatype;
import org.semanticweb.owlapi.model.OWLEntity;
import org.semanticweb.owlapi.model.OWLImportsDeclaration;
import org.semanticweb.owlapi.model.OWLNamedIndividual;
import org.semanticweb.owlapi.model.OWLObjectProperty;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyCreationException;
import org.semanticweb.owlapi.model.OWLOntologyID;
import org.semanticweb.owlapi.model.OWLOntologyManager;
import org.semanticweb.owlapi.model.OWLOntologyStorageException;
import org.semanticweb.owlapi.util.InferredAxiomGenerator;
import org.semanticweb.owlapi.util.InferredClassAssertionAxiomGenerator;
import org.semanticweb.owlapi.util.InferredDisjointClassesAxiomGenerator;
import org.semanticweb.owlapi.util.InferredEquivalentClassAxiomGenerator;
import org.semanticweb.owlapi.util.InferredEquivalentDataPropertiesAxiomGenerator;
import org.semanticweb.owlapi.util.InferredEquivalentObjectPropertyAxiomGenerator;
import org.semanticweb.owlapi.util.InferredInverseObjectPropertiesAxiomGenerator;
import org.semanticweb.owlapi.util.InferredOntologyGenerator;
import org.semanticweb.owlapi.util.InferredPropertyAssertionGenerator;
import org.semanticweb.owlapi.util.InferredSubClassAxiomGenerator;
import org.semanticweb.owlapi.util.InferredSubDataPropertyAxiomGenerator;
import org.semanticweb.owlapi.util.InferredSubObjectPropertyAxiomGenerator;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import com.clarkparsia.pellet.owlapiv3.PelletReasoner;
import com.clarkparsia.pellet.owlapiv3.PelletReasonerFactory;

/**
 * Servlet implementation class LodeServlet
 */
public class LodeServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private String xsltURL = "http://lode.sourceforge.net/xslt";
	private String cssLocation = "http://lode.sourceforge.net/css/";
	private int maxTentative = 1;
	private String host = "";
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public LodeServlet() {
        super();
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(
			HttpServletRequest request, HttpServletResponse response) 
	throws ServletException, IOException {
		response.setContentType("text/html; charset=UTF-8");
		
//		System.out.println(getServletContext().getContextPath());
//		System.out.println(request.getRemoteAddr());
//		System.out.println(request.getRequestURI());
//		System.out.println(request.getPathInfo());
//		System.out.println(request.getParameter("url"));
//		System.out.println(request.getHeader("Accept"));
		
		resolvePaths(request); /* Used instead of the SourceForge repo */
		response.setCharacterEncoding("UTF-8");
		PrintWriter out = response.getWriter();
		
		SourceExtractor extractor = new SourceExtractor(this);
		extractor.addMimeTypes(MimeType.mimeTypes);
		
		for (int i = 0; i < maxTentative; i++) {
			try {
				String stringURL = request.getParameter("url");
				
				URL ontologyURL = new URL(stringURL);
				
				String content = extractor.exec(ontologyURL);
			
				boolean useOWLAPI = new Boolean(request.getParameter("owlapi"));
				boolean considerImportedOntologies = 
					new Boolean(request.getParameter("imported"));
				boolean considerImportedClosure = 
					new Boolean(request.getParameter("closure"));
				boolean useReasoner = 
					new Boolean(request.getParameter("reasoner"));
				// added by Jan
				boolean ignoreStableSettings = 
						new Boolean(request.getParameter("nonstable"));
				boolean renderImports = 
						new Boolean(request.getParameter("renderimports"));
				
//				if (considerImportedOntologies || considerImportedClosure || useReasoner) {
					useOWLAPI = true;
//				}
				
				String lang = request.getParameter("lang");
				if (lang == null) {
					lang = "en";
				}
				
				content = parseWithOWLAPI(content, useOWLAPI, considerImportedOntologies, 
						considerImportedClosure, useReasoner);
				
				System.out.println(content);
				//Edited Start
				/*try {
					BufferedWriter out2 = new BufferedWriter(new FileWriter("test.xml"));
					out2.write(content);
					out2.close();
				}
				catch (IOException e)
				{
					System.out.println("Exception ");		
				}*/
				//Edited End
				
				content = applyXSLTTransformation(content, stringURL, lang, ignoreStableSettings, renderImports);
				
				out.println(content);
				i = maxTentative;
			} catch (Exception e) {
				if (i + 1 == maxTentative) {
					out.println(getErrorPage(e));
				}
			}
		}
	}
	
	private void resolvePaths(HttpServletRequest request) {
		xsltURL = getServletContext().getRealPath("/extraction.xsl");
		host = request.getHeader("host");
		cssLocation = "http://" + host + getServletContext().getContextPath() + File.separator;
	}

	private String parseWithOWLAPI(
			String content, boolean useOWLAPI,
			boolean considerImportedOntologies, 
			boolean considerImportedClosure,
			boolean useReasoner) 
	throws OWLOntologyCreationException, OWLOntologyStorageException {
		String result = content;
		
		// make utf-8
		// result=makeUTF8(result);
		
		if (useOWLAPI) {
			
			// Temporarily remove Import statements
			List<String> removed = new ArrayList<String>();
			if (!considerImportedClosure && !considerImportedOntologies) {
				result = removeImportedAxioms(result, removed);
			}
			
			OWLOntologyManager manager = OWLManager.createOWLOntologyManager(); 
			OWLOntology ontology = 
				manager.loadOntologyFromOntologyDocument(
						new StringDocumentSource(result));
			
			if (considerImportedClosure || considerImportedOntologies) {
				Set<OWLOntology> setOfImportedOntologies = new HashSet<OWLOntology>();
				if (considerImportedOntologies) {
					setOfImportedOntologies.addAll(ontology.getDirectImports());
				} else {
					setOfImportedOntologies.addAll(ontology.getImportsClosure());
				}
				
				for (OWLOntology importedOntology : setOfImportedOntologies) {
					manager.addAxioms(ontology, importedOntology.getAxioms());
				}
			}
			
			if (useReasoner) {
				ontology = parseWithReasoner(manager, ontology);
			}
			
			StringDocumentTarget parsedOntology = new StringDocumentTarget();
			
			manager.saveOntology(ontology, new RDFXMLOntologyFormat(), parsedOntology);
			result = parsedOntology.toString();
			
			// Recreate temporarily removed Import statements
			if (!removed.isEmpty() && !considerImportedClosure && !considerImportedOntologies) {
				result = addImportedAxioms(result, removed);
			} 
		}
		
		return result;
	}
	
	private String addImportedAxioms(String result, List<String> removed) {
		DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
	    factory.setNamespaceAware(true);
	    try {
			DocumentBuilder builder = factory.newDocumentBuilder();
			Document document = builder.parse(new ByteArrayInputStream(result.getBytes()));
			
			NodeList ontologies = 
				document.getElementsByTagNameNS("http://www.w3.org/2002/07/owl#", "Ontology");
			if (ontologies.getLength() > 0) {
				Element ontology = (Element) ontologies.item(0);
				
				for (String toBeAdded : removed) {
					Element importElement = 
						document.createElementNS("http://www.w3.org/2002/07/owl#","owl:imports");
					importElement.setAttributeNS(
							"http://www.w3.org/1999/02/22-rdf-syntax-ns#", "rdf:resource", toBeAdded);
					ontology.appendChild(importElement);
				}
			}
			
			Transformer transformer = TransformerFactory.newInstance().newTransformer();
			transformer.setOutputProperty(OutputKeys.ENCODING, "UTF-8");
			StreamResult output = new StreamResult(new StringWriter());
			DOMSource source = new DOMSource(document);
			transformer.transform(source, output);

			return output.getWriter().toString();
		} catch (ParserConfigurationException e) {
			return result;
		} catch (SAXException e) {
			return result;
		} catch (IOException e) {
			return result;
		} catch (TransformerConfigurationException e) {
			return result;
		} catch (TransformerFactoryConfigurationError e) {
			return result;
		} catch (TransformerException e) {
			return result;
		}
	}

	private String removeImportedAxioms(String result, List<String> removedImport) {
		DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
	    factory.setNamespaceAware(true);
	    try {
			DocumentBuilder builder = factory.newDocumentBuilder();
			Document document = builder.parse(new ByteArrayInputStream(result.getBytes()));
			
			NodeList ontologies = 
				document.getElementsByTagNameNS("http://www.w3.org/2002/07/owl#", "Ontology");
			for (int i = 0; i < ontologies.getLength() ; i++) {
				Element ontology = (Element) ontologies.item(i);
				
				NodeList children = ontology.getChildNodes();
				List<Element> removed = new ArrayList<Element>();
				for (int j = 0; j < children.getLength(); j++) {
					Node child = children.item(j);
					
					if (
							child.getNodeType() == Node.ELEMENT_NODE && 
							child.getNamespaceURI().equals("http://www.w3.org/2002/07/owl#") &&
							child.getLocalName().equals("imports")) {
						removed.add((Element) child);
					}
				}
				
				for (Element toBeRemoved : removed) {
					removedImport.add(toBeRemoved.getAttributeNS(
							"http://www.w3.org/1999/02/22-rdf-syntax-ns#", "resource"));
					ontology.removeChild(toBeRemoved);
				}
			}
			
			Transformer transformer = TransformerFactory.newInstance().newTransformer();
			transformer.setOutputProperty(OutputKeys.ENCODING, "UTF-8");
			StreamResult output = new StreamResult(new StringWriter());
			DOMSource source = new DOMSource(document);
			transformer.transform(source, output);

			return output.getWriter().toString();
		} catch (ParserConfigurationException e) {
			return result;
		} catch (SAXException e) {
			return result;
		} catch (IOException e) {
			return result;
		} catch (TransformerConfigurationException e) {
			return result;
		} catch (TransformerFactoryConfigurationError e) {
			return result;
		} catch (TransformerException e) {
			return result;
		}
	}
	
	/**
	 * Just serves as a workaround to make document UTF-8. This did only work for the owlapi mode otherwise. 
	 * @param result
	 * @return
	 */
	private String makeUTF8(String result) {
		DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
	    factory.setNamespaceAware(true);
	    try {
			DocumentBuilder builder = factory.newDocumentBuilder();
			Document document = builder.parse(new ByteArrayInputStream(result.getBytes()));
			
/*			NodeList ontologies = 
				document.getElementsByTagNameNS("http://www.w3.org/2002/07/owl#", "Ontology");
			if (ontologies.getLength() > 0) {
				Element ontology = (Element) ontologies.item(0);
				
				for (String toBeAdded : removed) {
					Element importElement = 
						document.createElementNS("http://www.w3.org/2002/07/owl#","owl:imports");
					importElement.setAttributeNS(
							"http://www.w3.org/1999/02/22-rdf-syntax-ns#", "rdf:resource", toBeAdded);
					ontology.appendChild(importElement);
				}
			}
			*/
			Transformer transformer = TransformerFactory.newInstance().newTransformer();
			transformer.setOutputProperty(OutputKeys.ENCODING, "UTF-8");
			StreamResult output = new StreamResult(new StringWriter());
			DOMSource source = new DOMSource(document);
			transformer.transform(source, output);

			return output.getWriter().toString();
		} catch (ParserConfigurationException e) {
			System.out.println(e);
			return result;
		} catch (SAXException e) {
			System.out.println("sax exception:");
			System.out.println(e);
			return result;
		} catch (IOException e) {
			System.out.println(e);
			return result;
		} catch (TransformerConfigurationException e) {
			System.out.println(e);
			return result;
		} catch (TransformerFactoryConfigurationError e) {
			System.out.println(e);
			return result;
		} catch (TransformerException e) {
			System.out.println(e);
			return result;
		}
	}

	private OWLOntology parseWithReasoner(OWLOntologyManager manager, OWLOntology ontology) {
		try {
			PelletOptions.load(new URL("http://" + host + getServletContext().getContextPath() + File.separator + "pellet.properties"));
			PelletReasoner reasoner = PelletReasonerFactory.getInstance().createReasoner(ontology);
			reasoner.getKB().prepare();
			List<InferredAxiomGenerator<? extends OWLAxiom>> generators=
				new ArrayList<InferredAxiomGenerator<? extends OWLAxiom>>();
	        generators.add(new InferredSubClassAxiomGenerator());
	        generators.add(new InferredClassAssertionAxiomGenerator());
	        generators.add(new InferredDisjointClassesAxiomGenerator());
	        generators.add(new InferredEquivalentClassAxiomGenerator());
	        generators.add(new InferredEquivalentDataPropertiesAxiomGenerator());
	        generators.add(new InferredEquivalentObjectPropertyAxiomGenerator());
	        generators.add(new InferredInverseObjectPropertiesAxiomGenerator());
	        generators.add(new InferredPropertyAssertionGenerator());
	        generators.add(new InferredSubDataPropertyAxiomGenerator());
	        generators.add(new InferredSubObjectPropertyAxiomGenerator());
	        
	        InferredOntologyGenerator iog = new InferredOntologyGenerator(reasoner, generators);
			
			OWLOntologyID id = ontology.getOntologyID();
			Set<OWLImportsDeclaration> declarations = ontology.getImportsDeclarations();
	        Set<OWLAnnotation> annotations = ontology.getAnnotations();
	        
	        Map<OWLEntity, Set<OWLAnnotationAssertionAxiom>> entityAnnotations = new HashMap<OWLEntity,Set<OWLAnnotationAssertionAxiom>>();
	        for (OWLClass aEntity  : ontology.getClassesInSignature()) {
	        	entityAnnotations.put(aEntity, aEntity.getAnnotationAssertionAxioms(ontology));
	        }
	        for (OWLObjectProperty aEntity : ontology.getObjectPropertiesInSignature()) {
	        	entityAnnotations.put(aEntity, aEntity.getAnnotationAssertionAxioms(ontology));
	        }
	        for (OWLDataProperty aEntity : ontology.getDataPropertiesInSignature()) {
	        	entityAnnotations.put(aEntity, aEntity.getAnnotationAssertionAxioms(ontology));
	        }
	        for (OWLNamedIndividual aEntity : ontology.getIndividualsInSignature()) {
	        	entityAnnotations.put(aEntity, aEntity.getAnnotationAssertionAxioms(ontology));
	        }
	        for (OWLAnnotationProperty aEntity : ontology.getAnnotationPropertiesInSignature()) {
	        	entityAnnotations.put(aEntity, aEntity.getAnnotationAssertionAxioms(ontology));
	        }
	        for (OWLDatatype aEntity : ontology.getDatatypesInSignature()) {
	        	entityAnnotations.put(aEntity, aEntity.getAnnotationAssertionAxioms(ontology));
	        }
	        
	        manager.removeOntology(ontology);
	        OWLOntology inferred = manager.createOntology(id);
			iog.fillOntology(manager, inferred);
			
			for (OWLImportsDeclaration decl : declarations) {
	        	manager.applyChange(new AddImport(inferred, decl));
	        }
	        for (OWLAnnotation ann : annotations) {
	        	manager.applyChange(new AddOntologyAnnotation(inferred, ann));
	        }
	        for (OWLClass aEntity : inferred.getClassesInSignature()) {
	        	applyAnnotations(aEntity, entityAnnotations, manager, inferred);
	        }
	        for (OWLObjectProperty aEntity : inferred.getObjectPropertiesInSignature()) {
	        	applyAnnotations(aEntity, entityAnnotations, manager, inferred);
	        }
	        for (OWLDataProperty aEntity : inferred.getDataPropertiesInSignature()) {
	        	applyAnnotations(aEntity, entityAnnotations, manager, inferred);
	        }
	        for (OWLNamedIndividual aEntity : inferred.getIndividualsInSignature()) {
	        	applyAnnotations(aEntity, entityAnnotations, manager, inferred);
	        }
	        for (OWLAnnotationProperty aEntity : inferred.getAnnotationPropertiesInSignature()) {
	        	applyAnnotations(aEntity, entityAnnotations, manager, inferred);
	        }
	        for (OWLDatatype aEntity : inferred.getDatatypesInSignature()) {
	        	applyAnnotations(aEntity, entityAnnotations, manager, inferred);
	        }
	        
			return inferred;
		} catch (FileNotFoundException e1) {
			return ontology;
		} catch (MalformedURLException e1) {
			return ontology;
		} catch (IOException e1) {
			return ontology;
		} catch (OWLOntologyCreationException e) {
			return ontology;
		}
	}

	private void applyAnnotations(
			OWLEntity aEntity, Map<OWLEntity, Set<OWLAnnotationAssertionAxiom>> entityAnnotations, 
			OWLOntologyManager manager, OWLOntology ontology) {
		Set<OWLAnnotationAssertionAxiom> entitySet = entityAnnotations.get(aEntity);
    	if (entitySet != null) {
    		for (OWLAnnotationAssertionAxiom ann : entitySet) {
    			manager.addAxiom(ontology, ann);
    		}
    	}
	}
	
	private String getErrorPage(Exception e) {
		return 
			"<html>" +
				"<head><title>LODE error</title></head>" +
				"<body>" +
					"<h2>" +
					"LODE error" +
					"</h2>" +
					"<p><strong>Reason: </strong>" +
					e.getMessage() +
					"</p>" +
				"</body>" +
			"</html>";
	}

	private String applyXSLTTransformation(String source, String ontologyUrl, String lang, boolean ignoreStableSettings, boolean renderImports) 
	throws TransformerException, UnsupportedEncodingException {	
		TransformerFactory tfactory = new net.sf.saxon.TransformerFactoryImpl();
		
		ByteArrayOutputStream output = new ByteArrayOutputStream();
		
		Transformer transformer =
			tfactory.newTransformer(
					new StreamSource(xsltURL));
		
		transformer.setParameter("css-location", cssLocation);
		transformer.setParameter("lang", lang);
		transformer.setParameter("ontology-url", ontologyUrl);
		transformer.setParameter("source", "http://" + host + getServletContext().getContextPath() + "/source");
		// added by Jan
		transformer.setParameter("ignore-stable", ignoreStableSettings);
		transformer.setParameter("render-imports", renderImports);
		transformer.setOutputProperty(OutputKeys.ENCODING, "UTF-8");
		
		StreamSource inputSource = new StreamSource(new StringReader(source));
		
		transformer.transform(
				inputSource, 
				new StreamResult(output));
		
		return output.toString("UTF-8");
	}
	
}
